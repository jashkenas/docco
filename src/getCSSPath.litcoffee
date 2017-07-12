This function determines the relative path of any html file in the destination folder to the css file.

    path        = require 'path'

    getCSSPath = (cssFile, targetDirectory, file) ->
      css = path.parse(cssFile)
      css.file = targetDirectory+'/'+css.base

      cssPath = path.relative(file, css.file)
      cssPath = cssPath.slice(3)

      cssPath

    module.exports = getCSSPath