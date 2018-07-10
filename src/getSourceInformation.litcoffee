    path        = require 'path'


    getSourceInformation = (file, rootDirectory, flatten) ->
      source = path.parse file
      source.root = rootDirectory
      source.file = file
      source.path = source.root+'/'+source.file
      if flatten
        source.relativefile = source.base
      else
        source.relativefile = source.file
      source

    module.exports = getSourceInformation