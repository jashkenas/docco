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
    output: output.replace(highlight_start, '').replace(highlight_end, '')
    fragments: output.split language.divider_html
    for section, i in sections
      section.code_html: highlight_start + fragments[i] + highlight_end
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
  title: path.basename source
  html:  docco_template {
    title: title, sections: sections, sources: sources, path: path, destination: destination
  }
  fs.writeFileSync destination(source), html

# Helpers
# -------

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

# Micro-templating, borrowed from John Resig, by way of
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

# The template that we use to generate the Docco HTML page.
docco_template: template fs.readFileSync './' + __dirname + '/resources/docco.jst'

# The start of each Pygments highlight block.
highlight_start: '<div class="highlight"><pre>'

# The end of each Pygments highlight block.
highlight_end: '</pre></div>'

# Run the script.
# For each source file passed in as an argument, generate the documentation.
sources: process.ARGV.sort()
generate_documentation source for source in sources
