    getRelativePath = require './getRelativePath'

    getOthers = (file, informationOnFiles, config) ->
      sourceFileInformation = informationOnFiles[file]
      source = sourceFileInformation.source
      others = {}
      for other in config.sources
        destinationFileInformation = informationOnFiles[other]
        target = destinationFileInformation.destination

        others[target.base] = {
          link: getRelativePath source.relativefile, target.relativefile, target.base
          file: other
        }

      others

    module.exports = getOthers
