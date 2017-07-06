
    path        = require 'path'


    getDestinationInformation = (language, source, rootDirectory, targetDirectory, flatten) ->
      destination = { }
      destination.root = rootDirectory

      if flatten and !language.copy
        destination.dir = targetDirectory
      else
        destination.dir = if source.dir is '' then targetDirectory else targetDirectory+"/"+source.dir

      if language.copy
        destination.ext = source.ext
      else
        destination.ext = '.html'

      destination.base = source.name + destination.ext
      destination.name = source.name
      destination.file = destination.dir+'/'+source.name + destination.ext
      if flatten and !language.copy
        destination.relativefile = source.name+destination.ext
      else
        destination.relativefile = if source.dir is '' then source.name+destination.ext else source.dir+'/'+source.name + destination.ext

      destination.path = destination.root+'/'+destination.file
      destination.pathdir = path.dirname destination.path

      destination

    module.exports = getDestinationInformation