var getSourceInformation, path;

path = require('path');

getSourceInformation = function(file, rootDirectory, flatten) {
  var source;
  source = path.parse(file);
  source.root = rootDirectory;
  source.file = file;
  source.path = source.root + '/' + source.file;
  if (flatten) {
    source.relativefile = source.base;
  } else {
    source.relativefile = source.file;
  }
  return source;
};

module.exports = getSourceInformation;

//# sourceMappingURL=getSourceInformation.js.map
