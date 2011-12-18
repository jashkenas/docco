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
# from [its Mercurial repo](http://dev.pocoo.org/hg/pygments-main)), and
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

#### Setup

# Require our external dependencies, including **Showdown.js**
# (the JavaScript implementation of Markdown).

fs = require "fs"
path = require "path"
showdown = require("./../vendor/showdown").Showdown
{request} = require "http"
{spawn, exec} = require "child_process"

#### Main Documentation Generation Functions

# Generate the documentation for a source file by reading it in, splitting it
# up into comment/code sections, highlighting them for the appropriate language,
# and merging them into an HTML template.
#
# The highlighting process prefers a local installation of the **Pygments**
# library, but will use a web service if Pygments is not installed. The
# latter requires an active Internet connection, and may not always support the
# latest version of Pygments.

# In the event that neither Pygments nor the web service is available, or the
# source code cannot be highlighted, plain text is produced instead.
generate_documentation = (source, callback) ->
  fs.readFile source, "utf-8", (error, code) ->
    throw error if error
    sections = parse source, code
    (if pygments_installed then highlight_pygments else highlight_webservice) source, sections, ->
      generate_html source, sections
      callback()

# Given a string of source code, parse out each comment and the code that
# follows it, and create an individual **section** for it.
# Sections take the form:
#
#     {
#       docs_text: ...
#       docs_html: ...
#       code_text: ...
#       code_html: ...
#     }
#
parse = (source, code) ->
  lines    = code.split "\n"
  sections = []
  language = get_language source
  has_code = docs_text = code_text = ""

  save = (docs, code) ->
    sections.push docs_text: docs, code_text: code

  for line in lines
    if line.match(language.comment_matcher) and not line.match(language.comment_filter)
      if has_code
        save docs_text, code_text
        has_code = docs_text = code_text = ""
      docs_text += line.replace(language.comment_matcher, "") + "\n"
    else
      has_code = yes
      code_text += line + "\n"
  save docs_text, code_text
  sections

# Detect if **Pygments** is installed by searching the load path for the
# `pygmentize` executable.
pygments_installed = do ->
  for path in process.env.PATH.split(":")
    try
      # The `mode` expresses the file mode in decimal form, and comprises the
      # file type, sticky bit, and three permission bits (owner, group, and
      # other users). We're only interested in the permission bits, so we
      # extract them from the mode by converting it into octal form and taking
      # the last three characters.
      permissions = fs.statSync("#{path}/pygmentize").mode.toString(8)[-3..]
      # The only executable bits are 1 (execute only), 3 (write and execute),
      # 5 (read and execute), and 7 (read, write, and execute). If at least
      # one of the permission bits is executable, we assume that the file is
      # executable.
      (return yes if permissions.charAt(index) % 2 == 1) for index in [0..3]
  no

# Highlights a single chunk of code, using **Pygments** over `stdio`, yielding
# to the `preprocess` function once highlighting is complete.
#
# We process the entire file in a single call to Pygments by inserting little
# marker comments between each section. The `preprocess` function then splits
# the resulting highlighted source code wherever our markers occur.
#
# The same process is used to highlight source code using the Pygments web
# service.
highlight_pygments = (source, sections, callback) ->
  language = get_language source
  pygments = spawn "pygmentize", ["-l", language.name, "-f", "html", "-O", "encoding=utf-8,tabsize=2"]
  output   = ""

  exception = ->
    console.warn "Warning: Pygments encountered an error while highlighting the source code."
    preprocess null, sections, results, callback

  pygments.stderr.addListener "data", exception
  pygments.stdin.addListener "error", exception

  pygments.stdout.addListener "data", (result) ->
    output += result if result

  pygments.addListener "exit", ->
    preprocess language, sections, output, callback

  if pygments.stdin.writable
    pygments.stdin.write((section.code_text for section in sections).join(language.divider_text))
    pygments.stdin.end()

# Converts all characters in a string to their corresponding hexadecimal HTML
# entities. This obfuscates the resulting HTML source, but ensures that all
# characters are properly escaped.
entitify = (value) ->
  results = ""
  results += "&#x#{value.charCodeAt(index).toString(16)};" for index in [0...value.length]
  results

# Preprocesses the highlighted source code, yielding to a callback function
# once the source and documentation have been converted to HTML.
#
# The documentation for the corresponding source code block is run through
# **Markdown**, using [Showdown.js](http://attacklab.net/showdown/).
preprocess = (language, sections, results, callback) ->
  if language?
    # If a language was specified, strip the Pygments block delimiters and
    # split the resulting HTML into a series of fragments. The highlighting
    # process automatically escapes HTML, so there is no need to preprocess
    # the blocks further.
    fragments = results.replace(highlight_start, "").replace(highlight_end, "").split(language.divider_html)
  else
    # If a language was not specified, we use the original source code block
    # associated with the documentation block. The `entitify` function is used
    # to convert all characters to their corresponding HTML entities, since the
    # code block is not escaped.
    fragments = (entitify(section.code_text) for section in sections)
  for section, index in sections
    section.code_html = highlight_start + fragments[index] + highlight_end
    section.docs_html = showdown.makeHtml section.docs_text
  callback()

# Highlights a block of code using the [Pygments web service](http://pygments.appspot.com/).
# The web service doesn't always use the latest version of Pygments, so not all
# languages supported by `pygmentize` can be used.
#
# If the server encounters an error or the Internet connection is offline, the
# source `language` is set to `null`. The `process` function will then treat the
# source as plain text.
highlight_webservice = (source, sections, callback) ->
  console.warn "Warning: Pygments is not installed. The web service will be used instead."
  language = get_language source
  results = ""
  transport = request host: "pygments.appspot.com", method: "post", (response) ->
    response.setEncoding "utf-8"

    response.on "data", (chunk) ->
      results += chunk

    response.on "end", ->
      unless 200 <= response.statusCode < 300
        language = null
        console.warn "Warning: The Pygments web service encountered an error."
      preprocess language, sections, results, callback

  transport.write "lang=#{encodeURIComponent(language.name)}&code=#{encodeURIComponent((section.code_text for section in sections).join(language.divider_text))}"

  transport.on "error", ->
    console.warn "Warning: The Internet connection is offline."
    preprocess null, sections, results, callback

  transport.end()

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. Pass the completed sections into the template
# found in `resources/docco.jst`
generate_html = (source, sections) ->
  title = path.basename source
  dest  = destination source
  html  = docco_template {
    title: title, sections: sections, sources: sources, path: path, destination: destination
  }
  console.log "docco: #{source} -> #{dest}"
  fs.writeFile dest, html

#### Helpers

# A list of the languages that Docco supports, mapping the file extension to
# the name of the Pygments lexer and the symbol that indicates a comment. To
# add another language to Docco's repertoire, add it here.
languages =
  '.coffee':
    name: 'coffee-script', symbol: '#'
  '.js':
    name: 'javascript', symbol: '//'
  '.rb':
    name: 'ruby', symbol: '#'
  '.py':
    name: 'python', symbol: '#'
  '.tex':
    name: 'tex', symbol: '%'
  '.latex':
    name: 'tex', symbol: '%'

# Build out the appropriate matchers and delimiters for each language.
for ext, l of languages

  # Does the line begin with a comment?
  l.comment_matcher = new RegExp('^\\s*' + l.symbol + '\\s?')

  # Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_(Unix\))
  # and interpolations...
  l.comment_filter = new RegExp('(^#![/]|^\\s*#\\{)')

  # The dividing token we feed into Pygments, to delimit the boundaries between
  # sections.
  l.divider_text = '\n' + l.symbol + 'DIVIDER\n'

  # The mirror of `divider_text` that we expect Pygments to return. We can split
  # on this to recover the original sections.
  # Note: the class is "c" for Python and "c1" for the other languages
  l.divider_html = new RegExp('\\n*<span class="c1?">' + l.symbol + 'DIVIDER<\\/span>\\n*')

# Get the current language we're documenting, based on the extension.
get_language = (source) -> languages[path.extname(source)]

# Compute the destination HTML path for an input source file path. If the source
# is `lib/example.coffee`, the HTML will be at `docs/example.html`
destination = (filepath) ->
  'docs/' + path.basename(filepath, path.extname(filepath)) + '.html'

# Ensure that the destination directory exists.
ensure_directory = (dir, callback) ->
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
docco_template  = template fs.readFileSync(__dirname + '/../resources/docco.jst').toString()

# The CSS styles we'd like to apply to the documentation.
docco_styles    = fs.readFileSync(__dirname + '/../resources/docco.css').toString()

# The start of each Pygments highlight block.
highlight_start = '<div class="highlight"><pre>'

# The end of each Pygments highlight block.
highlight_end   = '</pre></div>'

# Run the script.
# For each source file passed in as an argument, generate the documentation.
sources = process.ARGV.sort()
if sources.length
  ensure_directory 'docs', ->
    fs.writeFile 'docs/docco.css', docco_styles
    files = sources.slice(0)
    next_file = -> generate_documentation files.shift(), next_file if files.length
    next_file()
