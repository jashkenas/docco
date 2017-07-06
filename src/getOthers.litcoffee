    getRelativePath = require './getRelativePath'

    getOthers = (file, informationOnFiles, config) ->
      sourceFileInformation = informationOnFiles[file]
      source = sourceFileInformation.source
      others = {}
      for other in config.sources
        destinationFileInformation = informationOnFiles[other]
        target = destinationFileInformation.destination

        console.log(JSON.stringify(destinationFileInformation.destination,null,2))
        others[target.base] = getRelativePath source.relativefile, target.relativefile, target.base

      others

    module.exports = getOthers
