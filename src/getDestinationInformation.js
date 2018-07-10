var getDestinationInformation, path;

path = require('path');

getDestinationInformation = function(language, source, rootDirectory, targetDirectory, flatten) {
  var destination;
  destination = {};
  destination.root = rootDirectory;
  if (flatten && !language.copy) {
    destination.dir = targetDirectory;
  } else {
    destination.dir = source.dir === '' ? targetDirectory : targetDirectory + "/" + source.dir;
  }
  if (language.copy) {
    destination.ext = source.ext;
  } else {
    destination.ext = '.html';
  }
  destination.base = source.name + destination.ext;
  destination.name = source.name;
  destination.file = destination.dir + '/' + source.name + destination.ext;
  if (flatten && !language.copy) {
    destination.relativefile = source.name + destination.ext;
  } else {
    destination.relativefile = source.dir === '' ? source.name + destination.ext : source.dir + '/' + source.name + destination.ext;
  }
  destination.path = destination.root + '/' + destination.file;
  destination.pathdir = path.dirname(destination.path);
  return destination;
};

module.exports = getDestinationInformation;

//# sourceMappingURL=getDestinationInformation.js.map
