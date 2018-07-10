    _           = require 'underscore'
    fs          = require 'fs-extra'
    path        = require 'path'
    marked      = require 'marked'
    commander   = require 'commander'
    highlightjs = require 'highlight.js'
    path        = require 'path'
    glob        = require 'glob'


Once all of the code has finished highlighting, we can **write** the resulting
documentation file by passing the completed HTML sections into the template,
and rendering it to the specified output path.

    module.exports = write = (source, sections, config) ->

      # todo: figure out how to remove the breaking change here. normally this should return file+'.html'

      destination = (file) ->
        file

      objectValues = (obj) ->
        Object.keys(obj).map((key) ->
          obj[key]
        )

      firstSection = _.find sections, (section) ->
        section.docsText.length > 0
      first = marked.lexer(firstSection.docsText)[0] if firstSection
      hasTitle = first and first.type is 'heading' and first.depth is 1
      title = if hasTitle then first.text else path.basename source

      fileInfo = config.informationOnFiles[source]
      others = objectValues(fileInfo.others)
      links = others.map((o)-> return o.link)
      files = others.map((o)-> return o.file)
      html = config.template {
        sources: links,
        files: files,
        links: others,
        css: fileInfo.destination.css,
        title,
        hasTitle,
        sections,
        path,
        destination,
        flatten: config.flatten
      }

      console.log "docco: #{source} -> #{destination fileInfo.destination.path}"
      fs.writeFileSync destination(fileInfo.destination.path), html
      return
