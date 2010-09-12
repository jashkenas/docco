# **Docco** is a quick-and-dirty, hundred-line-long, literate-programming-style
# documentation generator. It produces HTML that displays your comments
# alongside your code. Comments are passed through
# [Markdown](http://daringfireball.net/projects/markdown/syntax), and code is
# passed through [Pygments](http://pygments.org/) syntax highlighting.
# This page is the result of running Docco against its own source file.
#
# If you install Docco, you can run it from the command-line:
#
#     > docco src/*.coffee
#
# ...will generate linked HTML documentation for the named source files, saving
# it into a `docs` folder.
#
# To install Docco, first make sure you have [Node.js](http://nodejs.org/),
# [Pygments](http://pygments.org/) (install the latest dev version of Pygments
# from [its Mercurial repo](http://dev.pocoo.org/hg/pygments-main)), and
# [CoffeeScript](http://coffeescript.org/). Then, with NPM:
#
#     > sudo npm install docco
#
# If **Node.js** doesn't run on your platform, or you'd prefer a more convenient
# package, get [Rocco](http://rtomayko.github.com/rocco/), the Ruby port that's
# available as a gem. If you're writing shell scripts, try
# [Shocco](http://rtomayko.github.com/shocco/), a port for the **POSIX shell**.
# Both are by [Ryan Tomayko](http://github.com/rtomayko). If Python's more
# your speed, take a look at [Nick Fitzgerald](http://github.com/fitzgen)'s
# [Pycco](http://fitzgen.github.com/pycco/).

#### Examples and Usage

# Generally, docco will be used from the command line.
#
#     > docco foo.js
#
# However, it can also be used from code.
#
#     assert = require 'assert'
#     path = require 'path'
#     assertPathExists = (p) -> assert.ok path.existsSync(p), p
#     
#     docco = require 'docco'
#     docco.generate ['src/docco.coffee']
#     assertPathExists 'test/docco_examples.coffee'
#     assertPathExists 'docs/docco.html'

#### Main Documentation Generation Functions

# Generate the documentation for a source file by reading it in, splitting it
# up into comment/code sections, highlighting them for the appropriate language,
# and merging them into an HTML template.
generate_documentation = (source, sources, callback) ->
  fs.readFile source, "utf-8", (error, code) ->
    throw error if error
    sections = parse source, code
    puts "docco: #{source}"
    highlight source, sections, ->
      generate_html source, sources, sections
      generate_tests source, sections
      callback()

# Given a string of source code, parse out each comment and the code that
# follows it, and create an individual **section** for it.
#
# Examples:
#
#     parsed = docco.parse "example.coffee", """
#       # Some docs.
#       #     assert.ok 'a test'
#       myCode()"""
#     assert.deepEqual parsed, [{
#       docs: "Some docs.\n    assert.ok 'a test'\n",
#       test: "assert.ok 'a test'\n",
#       code: "myCode()\n" }]
exports.parse = parse = (source, code) ->
  lines    = code.split '\n'
  sections = []
  language = get_language source
  has_code = docs_text = code_text = test_text = ''

  save = ->
    sections.push docs: docs_text, code: code_text, test: test_text

  for line in lines
    if line.match language.comment_matcher
      if has_code
        save()
        has_code = docs_text = test_text = code_text = ''

      line = line.replace(language.comment_matcher, '') + '\n'
      docs_text += line

      if line.match /^( {4}|\t)[^>]/
        test_text += line.replace(/^( {4}|\t)/, '')
    else
      has_code = yes
      code_text += line + '\n'
  save()
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
    puts error if error
  pygments.stdout.addListener 'data', (result) ->
    output += result if result
  pygments.addListener 'exit', ->
    output = output.replace(highlight_start, '').replace(highlight_end, '')
    fragments = output.split language.divider_html
    for section, i in sections
      section.code_html = highlight_start + fragments[i] + highlight_end
      section.docs_html = showdown.makeHtml section.docs
    callback()
  pygments.stdin.write((section.code for section in sections).join(language.divider_text))
  pygments.stdin.end()

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. Pass the completed sections into the template
# found in `resources/docco.jst`
generate_html = (source, sources, sections) ->
  title = path.basename source
  dest  = destination source
  html  = docco_template {
    title: title, sections: sections, sources: sources, path: path, destination: destination
  }
  puts "  -> #{dest}"
  fs.writeFile dest, html

generate_tests = (source, sections) ->
  dest = test_destination source
  language = get_language source
  puts "  -> #{dest}"
  fd = fs.openSync dest, 'w+'
  for section in sections when section.test
    comment = section.code?.split("\n")[0]
    fs.writeSync fd, "#{language.symbol} ## #{comment}\n" if comment
    fs.writeSync fd, section.test + "\n\n"
  fs.closeSync fd

#### Helpers & Setup

# Require our external dependencies, including **Showdown.js**
# (the JavaScript implementation of Markdown).
fs       = require 'fs'
path     = require 'path'
showdown = require('./../vendor/showdown').Showdown
{spawn, exec} = require 'child_process'
{puts, print} = require 'sys'

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

# Build out the appropriate matchers and delimiters for each language.
for ext, l of languages

  # Does the line begin with a comment?
  l.comment_matcher = new RegExp('^\\s*' + l.symbol + '\\s?')

  # The dividing token we feed into Pygments, to delimit the boundaries between
  # sections.
  l.divider_text = '\n' + l.symbol + 'DIVIDER\n'

  # The mirror of `divider_text` that we expect Pygments to return. We can split
  # on this to recover the original sections.
  l.divider_html = new RegExp('\\n*<span class="c1">' + l.symbol + 'DIVIDER<\\/span>\\n*')

# Get the current language we're documenting, based on the extension.
get_language = (source) -> languages[path.extname(source)]

# Compute the destination HTML path for an input source file path. If the source
# is `lib/example.coffee`, the HTML will be at `docs/example.html`
destination = (filepath) ->
  'docs/' + path.basename(filepath, path.extname(filepath)) + '.html'

test_destination = (filepath) ->
  'test/' + path.basename(filepath, path.extname(filepath)) + '_examples' + path.extname(filepath)

# Ensure that the destination directory exists.
ensure_directories = (callback) ->
  exec 'mkdir -p docs test', -> callback()

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

# For each source file passed in as an argument, generate the documentation.
exports.generate = (sources) ->
  ensure_directories ->
    fs.writeFile 'docs/docco.css', docco_styles
    files = sources.slice(0)
    next_file = -> generate_documentation files.shift(), sources, next_file if files.length
    next_file()

