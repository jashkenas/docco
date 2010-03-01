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
  code:     fs.readFileSync source
  sections: parse code
  counter:  sections.length
  for section in sections
    highlight section, ->
      counter -= 1
      generate_html source, sections if counter is 0

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

# Highlights a single chunk of CoffeeScript code, using **Pygments** over stdio,
# and runs the text of its corresponding comment through **Markdown**, using the
# **Github-flavored-Markdown** modification of **Showdown.js**.
highlight: (section, callback) ->
  pygments: process.createChildProcess 'pygmentize', ['-l', 'coffee-script', '-f', 'html']
  pygments.addListener 'output', (result) ->
    if result
      section.code_html: result
      section.docs_html: showdown.makeHtml section.docs_text
      callback()
  pygments.write section.code_text
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
    if line.match comment_matcher
      if has_code
        save docs_text, code_text
        has_code: docs_text: code_text: ''
      docs_text += line.replace(comment_matcher, '') + '\n'
    else
      has_code: true
      code_text += line + '\n'
  save docs_text, code_text
  sections

# Does the line begin with a comment?
comment_matcher: /^\s*#\s?/

# Compute the destination HTML path for an input source file.
destination: (filepath) ->
  path.basename(filepath, path.extname(filepath)) + '.html'

# Run the script.
# For each source file passed in as an argument, generate the documentation.
generate_documentation source for source in process.ARGV
