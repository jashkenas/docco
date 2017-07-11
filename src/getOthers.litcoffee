    getRelativePath = require './getRelativePath'

    getOthers = (file, informationOnFiles, config) ->
      sourceFileInformation = informationOnFiles[file]
      source = sourceFileInformation.source
      others = {}
      for other in config.sources
        destinationFileInformation = informationOnFiles[other]
        target = destinationFileInformation.destination
        image = destinationFileInformation.language.name is 'image'

        others[target.base] = {
          link: getRelativePath source.relativefile, target.relativefile, target.base
          file: other
          image: image
        }

      others

    module.exports = getOthers
