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
# To install Docco, first make sure you have [Node.js](http://nodejs.org/) and
# [CoffeeScript](http://coffeescript.org/). Then, to install system-wide in
# `/usr/local`:
#
#     sudo cake install
#
# If **Node.js** doesn't run on your platform, or you'd prefer a more convenient
# package, get [Rocco](http://rtomayko.github.com/rocco/), the Ruby port that's
# available as a gem.

#### Main Documentation Generation Functions

# Generate the documentation for a source file by reading it in, splitting it
# up into comment/code sections, highlighting them for the appropriate language,
# and merging them into an HTML template.
generate_documentation: (source, callback) ->
  fs.readFile source, (error, code) ->
    throw error if error
    sections: parse source, code
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
parse: (source, code) ->
  lines: code.split '\n'
  sections: []
  language: get_language source
  has_code: docs_text: code_text: ''

  save: (docs, code) ->
    sections.push {
      docs_text: docs
      code_text: code
    }

  for line in lines
    if line.match language.comment_matcher
      if has_code
        save docs_text, code_text
        has_code: docs_text: code_text: ''
      docs_text += line.replace(language.comment_matcher, '') + '\n'
    else
      has_code: true
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
highlight: (source, sections, callback) ->
  language: get_language source
  pygments: process.createChildProcess 'pygmentize', ['-l', language.name, '-f', 'html']
  output: ''
  pygments.addListener 'error',  (error)  ->
    process.stdio.writeError error if error
  pygments.addListener 'output', (result) ->
    output += result if result
  pygments.addListener 'exit', ->
    output: output.replace(highlight_start, '').replace(highlight_end, '')
    fragments: output.split language.divider_html
    for section, i in sections
      section.code_html: highlight_start + fragments[i] + highlight_end
      section.docs_html: showdown.makeHtml section.docs_text
    callback()
  pygments.write((section.code_text for section in sections).join(language.divider_text))
  pygments.close()

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. Pass the completed sections into the template
# found in `resources/docco.jst`
generate_html: (source, sections) ->
  title: path.basename source
  dest:  destination source
  html:  docco_template {
    title: title, sections: sections, sources: sources, path: path, destination: destination
  }
  puts "docco: $source -> $dest"
  fs.writeFile dest, html

#### Helpers & Setup

# Require our external dependencies, including **Showdown.js**
# (the JavaScript implementation of Markdown).
require.paths.unshift __dirname
fs:       require 'fs'
path:     require 'path'
showdown: require('vendor/showdown').Showdown

# A list of the languages that Docco supports, mapping the file extension to
# the name of the Pygments lexer and the symbol that indicates a comment. To
# add another language to Docco's repertoire, add it here.
languages: {
  '.coffee': {name: 'coffee-script', symbol: '#'}
  '.js':     {name: 'javascript',    symbol: '//'}
  '.rb':     {name: 'ruby',          symbol: '#'}
}

# Build out the appropriate matchers and delimiters for each language.
for ext, l of languages

  # Does the line begin with a comment?
  l.comment_matcher: new RegExp('^\\s*' + l.symbol + '\\s?')

  # The dividing token we feed into Pygments, to delimit the boundaries between
  # sections.
  l.divider_text: '\n' + l.symbol + 'DIVIDER\n'

  # The mirror of `divider_text` that we expect Pygments to return. We can split
  # on this to recover the original sections.
  l.divider_html: new RegExp('\\n*<span class="c1">' + l.symbol + 'DIVIDER<\\/span>\\n*')

# Get the current language we're documenting, based on the extension.
get_language: (source) -> languages[path.extname(source)]

# Compute the destination HTML path for an input source file path. If the source
# is `lib/example.coffee`, the HTML will be at `docs/example.html`
destination: (filepath) ->
  'docs/' + path.basename(filepath, path.extname(filepath)) + '.html'

# Ensure that the destination directory exists.
ensure_directory: (callback) ->
  exec 'mkdir -p docs', -> callback()

# Micro-templating, originally by John Resig, borrowed by way of
# [Underscore.js](http://documentcloud.github.com/underscore/).
template: (str) ->
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
docco_template:  template fs.readFileSync __dirname + '/resources/docco.jst'

# The CSS styles we'd like to apply to the documentation.
docco_styles:    fs.readFileSync __dirname + '/resources/docco.css'

# The start of each Pygments highlight block.
highlight_start: '<div class="highlight"><pre>'

# The end of each Pygments highlight block.
highlight_end:   '</pre></div>'

# Run the script.
# For each source file passed in as an argument, generate the documentation.
sources: process.ARGV.sort()
if sources.length
  ensure_directory ->
    fs.writeFile 'docs/docco.css', docco_styles
    files: sources.slice(0)
    next_file: -> generate_documentation files.shift(), next_file if files.length
    next_file()
