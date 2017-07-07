    _           = require 'underscore'
    fs          = require 'fs-extra'
    path        = require 'path'
    marked      = require 'marked'
    commander   = require 'commander'
    highlightjs = require 'highlight.js'
    path        = require 'path'
    glob        = require 'glob'

    getLanguage = require './getLanguage'
    parse = require './parse'
    format = require './format'
    write = require './write'

Generate the documentation for our configured source file by copying over static
assets, reading all the source files in, splitting them up into prose+code
sections, highlighting each file in the appropriate language, and printing them
out in an HTML template.

    document = (config = {}, languages, callback) ->

      fs.mkdirs config.output, ->

        callback or= (error) -> throw error if error
        copyAsset  = (file, callback) ->
          return callback() unless fs.existsSync file
          fs.copy file, path.join(config.output, path.basename(file)), callback

        complete   = ->
          copyAsset config.css, (error) ->
            return callback error if error
            return copyAsset config.public, callback if fs.existsSync config.public
            callback()

        files = config.sources.slice()

        nextFile = () ->
          source = files.shift()

If keeping the directory hierarchy, then insert the file's relative directory in to the path.

          console.log("Extension: "+config.extension)
          console.log("languages:" +languages)
          language = getLanguage source, languages, config.extension

          if config.flatten and !language.copy
            toDirectory = config.output
          else
            toDirectory = config.root + '/' + config.output + '/' + (path.dirname source)

Make sure the target directory exits.

          # todo: async versions of exits and mkdir.
          if !fs.existsSync(toDirectory)
            fs.mkdirsSync(toDirectory)

Implementation of copying files if specified in the language file

          if language.copy
            toFile = toDirectory + '/' + path.basename source
            console.log "docco: #{source} -> #{toFile}"
  
            fs.copy source, toFile, (error, result) ->
              return callback(error) if error
              if files.length then nextFile() else complete()

Implementation of spliting comments and code into split view html files.

          else
            fs.readFile source, (error, buffer) ->
              return callback(error) if error

              code = buffer.toString()
              console.log "docco Code: #{code} "
              console.log "docco Language: #{JSON.stringify(language)} "

              sections = parse source, language, code, config
              format source, language, sections, config
              toFile = toDirectory + '/' + (path.basename source, path.extname source)

              write source, sections, config
              if files.length then nextFile() else complete()

        nextFile()
      return

    module.exports = document

