This function determines the relative path of any html file in the destination folder to the css file.

    path        = require 'path'

    getRelativePath = (fromFile, toFile, base) ->
      fromTo = path.relative(fromFile,toFile)
      if fromTo is '' or fromTo is '.' or fromTo is '..' or fromTo is '../'
        fromTo = base
      else
        fromTo = fromTo.slice(3)

      fromTo
      
    module.exports = getRelativePath