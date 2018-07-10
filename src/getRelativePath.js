var getRelativePath, path;

path = require('path');

getRelativePath = function(fromFile, toFile, base) {
  var fromTo;
  fromTo = path.relative(fromFile, toFile);
  if (fromTo === '' || fromTo === '.' || fromTo === '..' || fromTo === '../') {
    fromTo = base;
  } else {
    fromTo = fromTo.slice(3);
  }
  return fromTo;
};

module.exports = getRelativePath;

//# sourceMappingURL=getRelativePath.js.map
