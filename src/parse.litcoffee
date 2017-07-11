    _           = require 'underscore'
    fs          = require 'fs-extra'
    path        = require 'path'
    marked      = require 'marked'
    commander   = require 'commander'
    highlightjs = require 'highlight.js'
    path        = require 'path'
    glob        = require 'glob'
    htmlImageMatcher = /^<img .*\/>/

Given a string of source code, **parse** out each block of prose and the code that
follows it — by detecting which is which, line by line — and then create an
individual **section** for it. Each section is an object with `docsText` and
`codeText` properties, and eventually `docsHtml` and `codeHtml` as well.

    module.exports = parse = (source, language, code, config = {}) ->
      lines    = code.split '\n'
      sections = []

      hasCode  = docsText = codeText = ''

      save = ->
        sections.push {docsText, codeText}
        hasCode = docsText = codeText = ''
        return

Our quick-and-dirty implementation of the literate programming style. Simply
invert the prose and code relationship on a per-line basis, and then continue as
normal below.

      if language.literate
        isText = maybeCode = yes
        for line, i in lines
          lines[i] = if maybeCode and match = /^([ ]{4}|[ ]{0,3}\t)/.exec line
            isText = no
            line[match[0].length..]
          else if maybeCode = /^\s*$/.test line
            if isText then language.symbol else ''
          else
            isText = yes
            language.symbol + ' ' + line

      for line in lines
        if language.linkMatcher and line.match(language.linkMatcher)
          LINK_REGEX = /\((.+)\)/
          TEXT_REGEX = /\[(.+)\]/
          STYLE_REGEX = /\{(.+)\}/
          links = LINK_REGEX.exec(line)
          texts = TEXT_REGEX.exec(line)
          styles = STYLE_REGEX.exec(line)
          if links? and links.length > 0 and texts? and texts.length > 1
            link = links[1]
            if texts and texts.length > 0 then text = texts[1] else text = ''
            if styles and styles.length > 0 then style = styles[1] else style = ''
            codeText += '<div><img src="'+link+'" style="'+style+'"></img><p>'+text+'</p></div>' + '\n'
          hasCode = yes
        else if line.match(htmlImageMatcher)  # only one per line!
          codeText += line
          hasCode = yes

        else if multilineComment and
        (language.stopMatcher and line.match(language.stopMatcher))
          multilineComment = false
          docsText += (line = line.replace(language.stopMatcher, '')) + '\n'
          save()
        else if multilineComment or
        (language.startMatcher and line.match(language.startMatcher))
          multilineComment = true
          save() if hasCode
          docsText += (line = line.replace(language.startMatcher, '')) + '\n'

        else if textToCode and
        (language.codeMatcher and line.match(language.codeMatcher))
          textToCode = false
          codeText += (line = line.replace(language.codeMatcher, '')) + '\n'
        else if textToCode or
        (language.codeMatcher and line.match(language.codeMatcher))
          textToCode = true
          hasCode = yes
          codeText += (line = line.replace(language.codeMatcher, '')) + '\n'

        else if language.sectionMatcher and line.match(language.sectionMatcher)
          save() if hasCode
          docsText += (line = line.replace(language.commentMatcher, '')) + '\n'
          save()
        else if line.match(language.commentMatcher) and not line.match(language.commentFilter)
          save() if hasCode
          docsText += (line = line.replace(language.commentMatcher, '')) + '\n'
          save() if /^(---+|===+)$/.test line
        else
          hasCode = yes
          codeText += line + '\n'
      save()

      sections

