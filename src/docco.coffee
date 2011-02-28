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
# ...will generate linked HTML documentation for the named source files, saving
# it into a `docs` folder.
#
# The [source for Docco](http://github.com/jashkenas/docco) is available on
# GitHub, and released under the MIT license.
#
# To install Docco, first make sure you have [Node.js](http://nodejs.org/),
# [Pygments](http://pygments.org/) (install the latest dev version of Pygments
# from [its Mercurial repo](http://dev.pocoo.org/hg/pygments-main)), and
# [CoffeeScript](http://coffeescript.org/). Then, with NPM:
#
#     sudo npm install docco
#
# If **Node.js** doesn't run on your platform, or you'd prefer a more convenient
# package, get [Rocco](http://rtomayko.github.com/rocco/), the Ruby port that's
# available as a gem. If you're writing shell scripts, try
# [Shocco](http://rtomayko.github.com/shocco/), a port for the **POSIX shell**.
# Both are by [Ryan Tomayko](http://github.com/rtomayko). If Python's more
# your speed, take a look at [Nick Fitzgerald](http://github.com/fitzgen)'s
# [Pycco](http://fitzgen.github.com/pycco/).


# Processes the command line arguments, returns a hash with options and an
# array of positional arguments for the source files. This allows the user to
# pass some flags from the command line rather than modifying the file
# everytime.
parse_args = ->
  opts    = {}
  sources = []
  args    = process.ARGV
  while arg = args.shift()
    # When we see a command line flag, do some slight processing on it, by
    # removing the preceding dashes first, and then grabbing the value it
    # refers to.
    #
    # We finish by sticking the arg=value pair in the `opts` object. Note
    # that no processing is done on the argument's value. We assume all of
    # them to be plain strings.
    if /^--?/.test arg
      arg = arg.replace /^--?/, ''
      opts[arg] = args.shift()

    # But if we don't get a command line flag, we just put the argument in
    # the sources list.
    else
      sources.push arg

  # And after all this small processing is done, we return an Array where the
  # first element is the `opts` object, and the second is the sources list.
  [opts, sources.sort()]


#### Main Documentation Generation Functions

# Generate the documentation for a source file by reading it in, splitting it
# up into comment/code sections, highlighting them for the appropriate language,
# and merging them into an HTML template.
generate_documentation = (source, callback) ->
  fs.readFile source, "utf-8", (error, code) ->
    throw error if error
    sections = parse source, code
    highlight source, sections, ->
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
  lines    = code.split '\n'
  sections = []
  language = get_language source
  has_code = docs_text = code_text = ''

  save = (docs, code) ->
    sections.push docs_text: docs, code_text: code

  for line in lines
    if line.match(language.comment_matcher) \
       and not line.match(language.comment_filter)
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
# **Github-flavored-Markdown** modification of
# [Showdown.js](http://attacklab.net/showdown/).
#
# We process the entire file in a single call to Pygments by inserting little
# marker comments between each section and then splitting the result string
# wherever our markers occur.
highlight = (source, sections, callback) ->
  language = get_language source
  pygments = spawn 'pygmentize', ['-l', language.name, '-f', 'html'
                                 ,'-O', 'encoding=utf-8']
  output   = ''
  pygments.stderr.addListener 'data',  (error)  ->
    console.error error if error
  pygments.stdout.addListener 'data', (result) ->
    output += result if result
  pygments.addListener 'exit', ->
    output = output.replace(highlight_start, '').replace(highlight_end, '')
    fragments = output.split language.divider_html
    for section, i in sections
      section.code_html = highlight_start + fragments[i] + highlight_end
      section.docs_html = showdown.makeHtml section.docs_text
    callback()

  sections_code = (section.code_text for section in sections)
  pygments.stdin.write(sections_code.join(language.divider_text))
  pygments.stdin.end()

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. Pass the completed sections into the template
# found in `resources/docco.jst`
generate_html = (source, sections) ->
  title = path.basename source
  dest  = destination source
  html  = docco_template {
    title:       title
    sections:    sections
    sources:     sources
    path:        path
    destination: destination
  }
  console.log "docco: #{source} -> #{dest}"
  fs.writeFile dest, html



#### Helpers & Setup

# Require our external dependencies, including **Showdown.js**
# (the JavaScript implementation of Markdown).
fs       = require 'fs'
path     = require 'path'
showdown = require('./../vendor/showdown').Showdown
{spawn, exec} = require 'child_process'

# Takes a quick peak at the arguments in the command line, grabs any flag that
# has been passed, so we can use it for overriding Docco's defaults, and use
# everything else as the actual source files.
#
# Accepted command line options are:
#
#     --css       the stylesheet to use for the documentation
#     --template  the template to use for the documentation
#     --output    the directory to save the documentation
[opts, sources] = parse_args()

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
  l.divider_html = new RegExp('\\n*<span class="c1?">' + l.symbol +
                              'DIVIDER<\\/span>\\n*')

# Get the current language we're documenting, based on the extension.
get_language = (source) -> languages[path.extname(source)]

# Compute the destination HTML path for an input source file path. If the source
# is `lib/example.coffee`, the HTML will be at `docs/example.html`
#
# `docs/` is the default output directory, however the user can specify any
# other directory by providing a `--output` commandline flag.
doc_dir = opts['output'] or 'docs'
destination = (filepath) ->
  doc_dir + path.basename(filepath, path.extname(filepath)) + '.html'

# Ensure that the destination directory exists.
ensure_directory = (callback) ->
  exec 'mkdir -p #{doc_dir}', -> callback()

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
#
# By default Docco will use the built-in template, however you can overwrite
# this by just passing `--template` in the command line rather than changing
# the default one.
template_path  = opts['template'] or (__dirname + '/../resources/docco.jst')
docco_template = template fs.readFileSync(template_path).toString()


# The CSS styles we'd like to apply to the documentation.
#
# By default Docco will use the built-in stylesheet, however you can overwrite
# this by just passing `--css` in the command line rather than changing the
# default one.
css_path     = opts['css'] or (__dirname + '/../resources/docco.css')
docco_styles = fs.readFileSync(css_path).toString()


# The start of each Pygments highlight block.
highlight_start = '<div class="highlight"><pre>'

# The end of each Pygments highlight block.
highlight_end   = '</pre></div>'


# Run the script and for each source file passed in as an argument.
# generates the documentation.
if sources.length
  ensure_directory ->
    fs.writeFile 'docs/docco.css', docco_styles
    next_file = ->
      generate_documentation sources.shift(), next_file if sources.length
    next_file()
