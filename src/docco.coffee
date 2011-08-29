# **Docco** is a quick-and-dirty, hundred-line-long, literate-programming-style
# documentation generator. It produces HTML that displays your comments
# alongside your code. Comments are passed through
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
#     sudo npm install docco
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
generate_documentation = (source, context, callback) ->
  fs.readFile source, "utf-8", (error, code) ->
    throw error if error
    sections = parse source, code
    highlight source, sections, ->
      generate_html source, context, sections
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
  lines    = code.split '\n'
  sections = []
  language = get_language source
  has_code = docs_text = code_text = ''

  save = (docs, code) ->
    sections.push docs_text: docs, code_text: code

  for line in lines
    if line.match(language.comment_matcher) and not line.match(language.comment_filter)
      if has_code
        save docs_text, code_text
        has_code = docs_text = code_text = ''
      docs_text += line.replace(language.comment_matcher, '') + '\n'
    else
      has_code = yes
      code_text += line + '\n'
  save docs_text, code_text
  sections

# Highlights a single chunk of CoffeeScript code, using **Pygments** over stdio,
# and runs the text of its corresponding comment through **Markdown**, using the
# **Github-flavored-Markdown** modification of [Showdown.js](http://attacklab.net/showdown/).
#
# We process the entire file in a single call to Pygments by inserting little
# marker comments between each section and then splitting the result string
# wherever our markers occur.
highlight = (source, sections, callback) ->
  language = get_language source
  pygments = spawn 'pygmentize', ['-l', language.name, '-f', 'html', '-O', 'encoding=utf-8']
  output   = ''
  
  pygments.stderr.addListener 'data',  (error)  ->
    console.error error.toString() if error
    
  pygments.stdin.addListener 'error',  (error)  ->
    console.error "Could not use Pygments to highlight the source."
    process.exit 1
    
  pygments.stdout.addListener 'data', (result) ->
    output += result if result
    
  pygments.addListener 'exit', ->
    output = output.replace(highlight_start, '').replace(highlight_end, '')
    fragments = output.split language.divider_html
    for section, i in sections
      section.code_html = highlight_start + fragments[i] + highlight_end
      section.docs_html = showdown.makeHtml section.docs_text
    callback()
    
  if pygments.stdin.writable
    pygments.stdin.write((section.code_text for section in sections).join(language.divider_text))
    pygments.stdin.end()
  
# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. Pass the completed sections into the template
# found in `resources/docco.jst`
generate_html = (source, context, sections) ->
  title = path.basename source
  dest  = destination source, context
  html  = docco_template {
    title: title, file_path: source, sections: sections, context: context, path: path, relative_base: relative_base
  }

  # Generate the file's base dir as required
  target_dir = path.dirname(dest)
  write_func = ->
    console.log "docco: #{source} -> #{dest}"
    fs.writeFile dest, html, (err) -> throw err if err

  fs.stat target_dir, (err, stats) ->
    throw err if err and err.code != 'ENOENT'

    return write_func() unless err

    if err
      exec "mkdir -p #{target_dir}", (err) ->
        throw err if err

        write_func()

#### Helpers & Setup

# Require our external dependencies, including **Showdown.js**
# (the JavaScript implementation of Markdown).
fs       = require 'fs'
path     = require 'path'
showdown = require('./../vendor/showdown').Showdown
{spawn, exec} = require 'child_process'

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

# Build out the appropriate matchers and delimiters for each language.
for ext, l of languages

  # Does the line begin with a comment?
  l.comment_matcher = new RegExp('^\\s*' + l.symbol + '\\s?')

  # Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_(Unix))
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

# Compute the path of a source file relative to the docs folder
relative_base = (filepath, context) ->
  result = if context.relative_root then path.dirname(filepath)[context.relative_root.length..] + '/' else ''

  if result == '/' then '' else result

# Compute the destination HTML path for an input source file path. If the source
# is `lib/example.coffee`, the HTML will be at `docs/example.html`.
destination = (filepath, context) ->
  base_path = relative_base filepath, context

  'docs/' + base_path + path.basename(filepath, path.extname(filepath)) + '.html'

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


# Process our arguments, passing an array of sources to generate docs for,
# and an optional relative root.
parse_args = (callback) ->
  args = process.ARGV.sort()

  # Preserving past behavior: if no args are given, we do nothing (eventually
  # display help?)
  return unless args.length

  # The traditional way of running docco is to just pass a globed list of files
  # to build docs for.
  unless args.length == 1 and fs.statSync(args[0]).isDirectory()
    return callback(args)

  # If we are given a single directory, treat this as a relative root and
  # recursively build docs that mirror its file and subdirectory structure.
  relative_root = args[0].replace(/\/+$/, '')

  # Rather than deal with building a recursive tree walker via the fs module,
  # let's save ourselves typing and testing and drop to the shell
  exec "find #{relative_root} -type f", (err, stdout) ->
    throw err if err

    # Don't include hidden files, either
    sources = stdout.split("\n").filter (file) -> file != '' and path.basename(file)[0] != '.'

    console.log "docco: Recursively generating docs underneath #{relative_root}/"

    callback(sources, relative_root + '/')

parse_args (sources, relative_root) ->
  # Rather than relying on globals, let's pass around a context w/ misc info
  # that we require down the line.
  context = sources: sources, relative_root: relative_root

  ensure_directory 'docs', ->
    fs.writeFile 'docs/docco.css', docco_styles
    files = sources.slice(0)
    next_file = -> generate_documentation files.shift(), context, next_file if files.length
    next_file()

