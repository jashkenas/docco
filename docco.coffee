fs:   require 'fs'
path: require 'path'

# Does the line begin with a comment?
comment_matcher: /^\s*#/

# Compute the destination HTML path for an input source file.
destination: (filepath) ->
  path.basename(filepath, path.extname(filepath)) + '.html'

# Wrap the HTML block in our template.
apply_template: (title, html) ->
  fs.readFileSync('resources/template.html')
    .replace 'DOCUMENTATION', html
    .replace 'TITLE', title

# Highlight a chunk of CoffeeScript code, using Pygments.
highlight: (section, callback) ->
  pygments: process.createChildProcess 'pygmentize', ['-l', 'coffee-script', '-f', 'html']
  pygments.addListener 'output', (result) ->
    if result
      section.html: result
      callback()
  pygments.write section.code
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
          comment: comment_text
          code:    code_text
        }
        has_code:     false
        comment_text: ''
        code_text:    ''
      comment_text += line.replace(comment_matcher, '') + '\n'
    else
      has_code: true
      code_text += line + '\n'
  sections

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation.
generate_html: (source, sections) ->
  title: path.basename(source)
  html: '<h1>' + title + '</h1>'
  for section in sections
    html += '<div class="doc">'  + section.comment + '</div>' +
            '<div class="code">' + section.html    + '</div>' +
            '<div class="divider"></div>'
  fs.writeFile destination(source), apply_template(title, html)

# Generate the HTML documentation for a CoffeeScript source file.
document: (source) ->
  code:     fs.readFileSync source
  sections: parse code
  counter:  sections.length
  for section in sections
    highlight section, ->
      counter -= 1
      generate_html source, sections if counter is 0

# For each source file passed in as an argument, generate the documentation.
document source for source in process.ARGV
