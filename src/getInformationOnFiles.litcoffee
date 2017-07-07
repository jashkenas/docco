    _           = require 'underscore'
    fs          = require 'fs-extra'
    path        = require 'path'
    marked      = require 'marked'
    commander   = require 'commander'
    highlightjs = require 'highlight.js'
    path        = require 'path'
    glob        = require 'glob'

    getSourceInformation = require './getSourceInformation'

    getDestinationInformation = require './getDestinationInformation'

    getRelativePath = require './getRelativePath'

    getCSSPath = require './getCSSPath'

    getOthers = require './getOthers'

    getLanguage = require './getLanguage'

    module.exports = getInformationOnFiles = (config) ->
      targetDirectory = config.output
      sourceDirectory = config.root
      rootDirectory = config.root

For each source file, figure out it's relative path to the source directory,
the filename without and extension, and the extension.  Then figure out the
relative path to the targetDirectory. Then figure out the relative path between
the two.

      informationOnFiles = {}
      for file in config.sources
        language = getLanguage file, config.languages, config.extension

First the source name:

        source = getSourceInformation(file, rootDirectory, config.flatten)

Next the destination:

        destinations = {}
        destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, config.flatten)

Now, figure out the relative paths the css:

        destination.css = getCSSPath(config.css, targetDirectory, destination.file)

        informationOnFiles[file] = {}
        informationOnFiles[file].destination = destination
        informationOnFiles[file].source = source
        informationOnFiles[file].language = language

Now, figure out the relative paths to the other source files:

      for file in config.sources
        informationOnFiles[file].others = getOthers(file, informationOnFiles, config)

      return informationOnFiles
