# **Docco** is a quick and dirty literate-programming-style documentation generator.
# It produces HTML that displays your comments alongside your code. Comments
# are passed through [Markdown](http://daringfireball.net/projects/markdown/syntax),
# and code is passed through [Pygments](http://pygments.org/) syntax highlighting.
#
# Currently, Docco can be run from the command-line like so:
#
#     coffee docco.coffee -- path/to/target.coffee

# External dependencies, including **Showdown.js** (the JavaScript implementation
# of Markdown).
fs:       require 'fs'
path:     require 'path'
showdown: require(process.cwd() + '/vendor/showdown').Showdown

# Generate the documentation for a source file by reading it in, splitting it
# up into comment/code sections, highlighting them, and generating the corresponding
# HTML. For the moment, we run a separate **Pygments** process for each section,
# which is quite wasteful. In the future, we should either use a JavaScript-based
# syntax highlighter, or insert section delimiters and run a single **Pygments** process.
generate_documentation: (source) ->
  set_language source
  code: fs.readFileSync source
  sections: parse code
  highlight source, sections, ->
    generate_html source, sections

# Highlights a single chunk of CoffeeScript code, using **Pygments** over stdio,
# and runs the text of its corresponding comment through **Markdown**, using the
# **Github-flavored-Markdown** modification of **Showdown.js**.
highlight: (source, sections, callback) ->
  pygments: process.createChildProcess 'pygmentize', ['-l', language.name, '-f', 'html']
  output: ''
  pygments.addListener 'error',  (error)  ->
    process.stdio.writeError error if error
  pygments.addListener 'output', (result) ->
    output += result if result
  pygments.addListener 'exit', ->
    fragments: output.split language.divider_html
    for section, i in sections
      section.code_html: '<div class="highlight"><pre>' + fragments[i] + '</pre></div>'
      section.docs_html: showdown.makeHtml section.docs_text
      callback()
  pygments.write((section.code_text for section in sections).join(language.divider_text))
  pygments.close()

# Parse out each comments and the code that follows into a individual section.
# Sections take the form:
#
#     {
#       docs_text: ...
#       docs_html: ...
#       code_text: ...
#       code_html: ...
#     }
#
parse: (code) ->
  lines: code.split '\n'
  sections: []
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

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. In the future, it would be nice to extract
# these HTML strings into a template.
generate_html: (source, sections) ->
  title: path.basename(source)
  html: '<thead><tr><th class="doc"><h1>' +
          title +
        '</h1></th><th class="code"></th></tr></thead>'
  for section in sections
    html += '<tr><td class="doc">' + section.docs_html + '</td>' +
            '<td class="code">'    + section.code_html + '</td></tr>'
  fs.writeFile destination(source), apply_template(title, html)

# Wrap the generated HTML block in our external template (doctype, body tag, etc).
apply_template: (title, html) ->
  fs.readFileSync('./' + __dirname + '/resources/template.html')
    .replace('DOCUMENTATION', html)
    .replace('TITLE', title)

# Helper Functions
# ----------------

# A map of the languages that Docco supports.
# File extension mapped to Pygments name and comment symbol.
languages: {
  '.coffee': {name: 'coffee-script', symbol: '#'}
  '.js':     {name: 'javascript',    symbol: '//'}
  '.rb':     {name: 'ruby',          symbol: '#'}
}

# The language of the current sourcefile.
language: null

# Set the current language we're documenting, based on the extension of the
# source file.
set_language: (source) ->
  l: language: languages[path.extname(source)]

  # Does the line begin with a comment? Handle `#` and `//` -style comments.
  l.comment_matcher ||= new RegExp('^\\s*' + l.symbol + '\\s?')

  # The dividing token we feed into Pygments, so that we can get all of the
  # sections to be highlighted in a single pass.
  l.divider_text ||= '\n' + l.symbol + 'DIVIDER\n'

  # The mirror of the divider that Pygments returns, that we split on in order
  # to recover the original sections.
  l.divider_html ||= new RegExp('\\n*<span class="c1">' + l.symbol + 'DIVIDER<\\/span>\\n*')

# Compute the destination HTML path for an input source file.
destination: (filepath) ->
  path.basename(filepath, path.extname(filepath)) + '.html'

# Run the script.
# For each source file passed in as an argument, generate the documentation.
generate_documentation source for source in process.ARGV
