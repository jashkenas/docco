This function determines the relative path of any html file in the destination folder to the css file.

    path        = require 'path'

    getRelativePath = (fromFile, toFile, base) ->
      console.log("From: #{fromFile} To: #{toFile}")
      fromTo = path.relative(fromFile,toFile)
      if fromTo is '' or fromTo is '.' or fromTo is '..' or fromTo is '../'
        fromTo = base
      else
        fromTo = fromTo.slice(3)

      console.log("Path: #{fromTo}")
      fromTo
      
    module.exports = getRelativePath