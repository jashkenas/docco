    _           = require 'underscore'
    fs          = require 'fs-extra'
    path        = require 'path'
    marked      = require 'marked'
    commander   = require 'commander'
    highlightjs = require 'highlight.js'
    path        = require 'path'
    glob        = require 'glob'


Given a string of source code, **parse** out each block of prose and the code that
follows it — by detecting which is which, line by line — and then create an
individual **section** for it. Each section is an object with `docsText` and
`codeText` properties, and eventually `docsHtml` and `codeHtml` as well.

    parse = (source, code, config = {}) ->
      lines    = code.split '\n'
      sections = []
      lang     = getLanguage source, config
      hasCode  = docsText = codeText = ''

      save = ->
        sections.push {docsText, codeText}
        hasCode = docsText = codeText = ''

Our quick-and-dirty implementation of the literate programming style. Simply
invert the prose and code relationship on a per-line basis, and then continue as
normal below.

      if lang.literate
        isText = maybeCode = yes
        for line, i in lines
          lines[i] = if maybeCode and match = /^([ ]{4}|[ ]{0,3}\t)/.exec line
            isText = no
            line[match[0].length..]
          else if maybeCode = /^\s*$/.test line
            if isText then lang.symbol else ''
          else
            isText = yes
            lang.symbol + ' ' + line

      for line in lines
        if lang.linkMatcher and line.match(lang.linkMatcher)
          LINK_REGEX = /\((.+)\)/
          TEXT_REGEX = /\[(.+)\]/
          links = LINK_REGEX.exec(line)
          texts = TEXT_REGEX.exec(line)
          if links? and links.length > 1 and texts? and texts.length > 1
            link = links[1]
            text = texts[1]
            codeText += '<div><img src="'+link+'"></img><p>'+text+'</p></div>' + '\n'
          hasCode = yes
        else if lang.sectionMatcher and line.match(lang.sectionMatcher)
          save() if hasCode
          docsText += (line = line.replace(lang.commentMatcher, '')) + '\n'
          save() # if /^(---+|===+)$/.test line
        else if line.match(lang.commentMatcher) and not line.match(lang.commentFilter)
          save() if hasCode
          docsText += (line = line.replace(lang.commentMatcher, '')) + '\n'
          save() if /^(---+|===+)$/.test line
        else
          hasCode = yes
          codeText += line + '\n'
      save()

      sections

  module.exports = parse