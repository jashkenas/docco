# **Docco** is a quick-and-dirty, hundred-line-long, literate-programming-style
# documentation generator. It produces HTML
# that displays your comments alongside your code. Comments are passed through
# [Markdown](http://daringfireball.net/projects/markdown/syntax), and code is
# passed through [Pygments](http://pygments.org/) syntax highlighting.
# This page is the result of running Docco against its own source file.
#
# If you install Docco, you can run it from the command-line:
#
#     docco src/*.coffee
#
# ...will generate an HTML documentation page for each of the named source files, 
# with a menu linking to the other pages, saving it into a `docs` folder.
#
# The [source for Docco](http://github.com/jashkenas/docco) is available on GitHub,
# and released under the MIT license.
#
# To install Docco, first make sure you have [Node.js](http://nodejs.org/),
# [Pygments](http://pygments.org/) (install the latest dev version of Pygments
# from [its Mercurial repo](https://bitbucket.org/birkenfeld/pygments-main)), and
# [CoffeeScript](http://coffeescript.org/). Then, with NPM:
#
#     sudo npm install -g docco
#
# Docco can be used to process CoffeeScript, JavaScript, Ruby, Python, or TeX files.
# Only single-line comments are processed -- block comments are ignored.
#
#### Partners in Crime:
#
# * If **Node.js** doesn't run on your platform, or you'd prefer a more 
# convenient package, get [Ryan Tomayko](http://github.com/rtomayko)'s 
# [Rocco](http://rtomayko.github.com/rocco/rocco.html), the Ruby port that's 
# available as a gem. 
# 
# * If you're writing shell scripts, try
# [Shocco](http://rtomayko.github.com/shocco/), a port for the **POSIX shell**,
# also by Mr. Tomayko.
# 
# * If Python's more your speed, take a look at 
# [Nick Fitzgerald](http://github.com/fitzgen)'s [Pycco](http://fitzgen.github.com/pycco/). 
#
# * For **Clojure** fans, [Fogus](http://blog.fogus.me/)'s 
# [Marginalia](http://fogus.me/fun/marginalia/) is a bit of a departure from 
# "quick-and-dirty", but it'll get the job done.
#
# * **Lua** enthusiasts can get their fix with 
# [Robert Gieseke](https://github.com/rgieseke)'s [Locco](http://rgieseke.github.com/locco/).
# 
# * And if you happen to be a **.NET**
# aficionado, check out [Don Wilson](https://github.com/dontangg)'s 
# [Nocco](http://dontangg.github.com/nocco/).

#### Main Documentation Generation Functions

# Generate the documentation for a source file by reading it in, splitting it
# up into comment/code sections, highlighting them for the appropriate language,
# and merging them into an HTML template.
generateDocumentation = (sources, source, callback) ->
  fs.readFile source, (error, buffer) ->
    throw error if error
    code = buffer.toString()
    sections = parse source, code
    highlight source, sections, ->
      generateHtml sources, source, sections
      callback()

# Given a string of source code, parse out each comment and the code that
# follows it, and create an individual **section** for it.
# Sections take the form:
#
#     {
#       docsText: ...
#       docsHtml: ...
#       codeText: ...
#       codeHtml: ...
#     }
#
parse = (source, code) ->
  lines    = code.split '\n'
  sections = []
  language = getLanguage source
  hasCode = docsText = codeText = ''

  save = (docsText, codeText) ->
    sections.push {docsText, codeText}

  for line in lines
    if line.match(language.commentMatcher) and not line.match(language.commentFilter)
      if hasCode
        save docsText, codeText
        hasCode = docsText = codeText = ''
      docsText += line.replace(language.commentMatcher, '') + '\n'
    else
      hasCode = yes
      codeText += line + '\n'
  save docsText, codeText
  sections

# Highlights a single chunk of CoffeeScript code, using **Pygments** over stdio,
# and runs the text of its corresponding comment through **Markdown**, using
# [Showdown.js](http://attacklab.net/showdown/).
#
# We process the entire file in a single call to Pygments by inserting little
# marker comments between each section and then splitting the result string
# wherever our markers occur.
highlight = (source, sections, callback) ->
  language = getLanguage source
  pygments = spawn 'pygmentize', [
    '-l', language.name,
    '-f', 'html',
    '-O', 'encoding=utf-8,tabsize=2'
  ]
  output   = ''
  
  pygments.stderr.addListener 'data',  (error)  ->
    console.error error.toString() if error
    
  pygments.stdin.addListener 'error',  (error)  ->
    console.error "Could not use Pygments to highlight the source."
    process.exit 1
    
  pygments.stdout.addListener 'data', (result) ->
    output += result if result
    
  pygments.addListener 'exit', ->
    output = output.replace(highlightStart, '').replace(highlightEnd, '')
    fragments = output.split language.dividerHtml
    for section, i in sections
      section.codeHtml = highlightStart + fragments[i] + highlightEnd
      section.docsHtml = showdown.makeHtml section.docsText
    callback()
    
  if pygments.stdin.writable
    text = (section.codeText for section in sections)
    pygments.stdin.write(text.join(language.dividerText))
    pygments.stdin.end()
  
# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. Pass the completed sections into the template
# found in `resources/docco.jst`
generateHtml = (sources, source, sections) ->
  title = path.basename source
  dest  = destination source
  html  = doccoTemplate {title, sections, sources, path, destination}
  console.log "docco: #{source} -> #{dest}"
  fs.writeFile dest, html

#### Helpers & Setup

# Require our external dependencies, including **Showdown.js**
# (the JavaScript implementation of Markdown).
fs       = require 'fs'
path     = require 'path'
showdown = require('./../vendor/showdown').Showdown
{spawn, exec} = require 'child_process'

# Read resource file and return its content.
getResource = (name) ->
  fullPath = path.join __dirname, '..', 'resources', name
  fs.readFileSync(fullPath).toString()

# Languages are stored in JSON format in the file `resources/languages.json`
# Each item maps the file extension to the name of the Pygments lexer and the
# symbol that indicates a comment. To add a new language, modify the file.
languages = JSON.parse getResource 'languages.json'

# Build out the appropriate matchers and delimiters for each language.
for ext, l of languages

  # Does the line begin with a comment?
  l.commentMatcher = ///^\s*#{l.symbol}\s?///

  # Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_(Unix\))
  # and interpolations...
  l.commentFilter = /(^#![/]|^\s*#\{)/

  # The dividing token we feed into Pygments, to delimit the boundaries between
  # sections.
  l.dividerText = "\n#{l.symbol}DIVIDER\n"

  # The mirror of `dividerText` that we expect Pygments to return. We can split
  # on this to recover the original sections.
  # Note: the class is "c" for Python and "c1" for the other languages
  l.dividerHtml = ///\n*<span\sclass="c1?">#{l.symbol}DIVIDER<\/span>\n*///

# Get the current language we're documenting, based on the extension.
getLanguage = (source) -> languages[path.extname(source)]

# Compute the destination HTML path for an input source file path. If the source
# is `lib/example.coffee`, the HTML will be at `docs/example.html`
destination = (filepath) ->
  basename = path.basename filepath, path.extname filepath
  "docs/#{basename}.html"

# Ensure that the destination directory exists.
ensureDirectory = (dir, callback) ->
  exec "mkdir -p #{dir}", -> callback()

# Micro-templating, originally by John Resig, borrowed by way of
# [Underscore.js](http://documentcloud.github.com/underscore/).
template = (str) ->
  new Function 'obj',
    'var p=[],print=function(){p.push.apply(p,arguments);};' +
    'with(obj){p.push(\'' +
    str.replace(/[\r\t\n]/g, " ")
       .replace(/'(?=[^<]*%>)/g,"\t")
       .split("'").join("\\'")
       .split("\t").join("'")
       .replace(/<%=(.+?)%>/g, "',$1,'")
       .split('<%').join("');")
       .split('%>').join("p.push('") +
       "');}return p.join('');"

# Create the template that we will use to generate the Docco HTML page.
doccoTemplate  = template getResource 'docco.jst'

# The CSS styles we'd like to apply to the documentation.
doccoStyles    = getResource 'docco.css'

# The start of each Pygments highlight block.
highlightStart = '<div class="highlight"><pre>'

# The end of each Pygments highlight block.
highlightEnd   = '</pre></div>'

# Run the script.
# For each source file passed in as an argument, generate the documentation.
exports.generate = (list) ->
  return throw new Error "No files for docco" unless list.length
  sources = list.slice().sort()
  ensureDirectory 'docs', ->
    fs.writeFile 'docs/docco.css', doccoStyles
    files = sources.slice(0)
    nextFile = ->
      generateDocumentation sources, files.shift(), nextFile if files.length
    nextFile()
