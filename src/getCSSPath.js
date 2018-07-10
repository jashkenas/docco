var getCSSPath, path;

path = require('path');

getCSSPath = function(cssFile, targetDirectory, file) {
  var css, cssPath;
  css = path.parse(cssFile);
  css.file = targetDirectory + '/' + css.base;
  cssPath = path.relative(file, css.file);
  cssPath = cssPath.slice(3);
  return cssPath;
};

module.exports = getCSSPath;

//# sourceMappingURL=getCSSPath.js.map
