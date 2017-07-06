    _           = require 'underscore'
    fs          = require 'fs-extra'
    path        = require 'path'
    marked      = require 'marked'
    commander   = require 'commander'
    highlightjs = require 'highlight.js'
    path        = require 'path'
    glob        = require 'glob'

To **format** and highlight the now-parsed sections of code, we use **Highlight.js**
over stdio, and run the text of their corresponding comments through
**Markdown**, using [Marked](https://github.com/chjj/marked).

    format = (source, language, sections, config) ->

Pass any user defined options to Marked if specified via command line option

      markedOptions =
        smartypants: true

      if config.marked
        markedOptions = config.marked

      marked.setOptions markedOptions

Tell Marked how to highlight code blocks within comments, treating that code
as either the language specified in the code block or the language of the file
if not specified.

      marked.setOptions {
        highlight: (code, language) ->
          language or= language.name

          if highlightjs.getLanguage(language)
            highlightjs.highlight(language, code).value
          else
            console.warn "docco: couldn't highlight code block with unknown language '#{language}' in #{source}"
            code
      }

      for section, i in sections
        if language.html
          section.codeHtml = section.codeText
        else
          code = highlightjs.highlight(language.name, section.codeText).value
          code = code.replace(/\s+$/, '')
          section.codeHtml = "<div class='highlight'><pre>#{code}</pre></div>"
        section.docsHtml = marked(section.docsText)

    module.exports = format