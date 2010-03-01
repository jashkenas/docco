# External dependencies, including Showdown.js
fs:       require 'fs'
path:     require 'path'
showdown: require(process.cwd() + '/vendor/showdown').Showdown

# Does the line begin with a comment?
comment_matcher: /^\s*#\s?/

# Compute the destination HTML path for an input source file.
destination: (filepath) ->
  'output/' + path.basename(filepath, path.extname(filepath)) + '.html'

# Wrap the HTML block in our template.
apply_template: (title, html) ->
  fs.readFileSync('./' + __dirname + '/resources/template.html')
    .replace('DOCUMENTATION', html)
    .replace('TITLE', title)

# Highlight a chunk of CoffeeScript code, using **Pygments**, and run the text of
# its corresponding comment through **Markdown**, using the **Github-flavored-Markdown**
# modification of **Showdown.js**.
highlight: (section, callback) ->
  pygments: process.createChildProcess 'pygmentize', ['-l', 'coffee-script', '-f', 'html']
  pygments.addListener 'output', (result) ->
    if result
      section.code_html:    result
      section.comment_html: showdown.makeHtml section.comment_text
      callback()
  pygments.write section.code_text
  pygments.close()

# Parse out comments and the code that follows into an individual section.
parse: (code) ->
  lines:        code.split '\n'
  sections:     []
  has_code:     false
  comment_text: ''
  code_text:    ''
  for line in lines
    if line.match comment_matcher
      if has_code
        sections.push {
          comment_text: comment_text
          code_text:    code_text
        }
        has_code:     false
        comment_text: ''
        code_text:    ''
      comment_text += line.replace(comment_matcher, '') + '\n'
    else
      has_code: true
      code_text += line + '\n'
  sections.push {
    comment_text: comment_text
    code_text:    code_text
  }
  sections

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation.
generate_html: (source, sections) ->
  title: path.basename(source)
  html: '<thead><tr><th class="doc"><h1>' + title + '</h1></th><th class="code"></th></tr></thead>'
  for section in sections
    html += '<tr><td class="doc">'  + section.comment_html + '</td>' +
            '<td class="code">' + section.code_html    + '</td></tr>'
  fs.writeFile destination(source), apply_template(title, html)

# Generate the HTML documentation for a CoffeeScript source file.
generate_documentation: (source) ->
  code:     fs.readFileSync source
  sections: parse code
  counter:  sections.length
  for section in sections
    highlight section, ->
      counter -= 1
      generate_html source, sections if counter is 0

# For each source file passed in as an argument, generate the documentation.
generate_documentation source for source in process.ARGV
