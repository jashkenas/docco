var getOthers, getRelativePath;

getRelativePath = require('./getRelativePath');

getOthers = function(file, informationOnFiles, config) {
  var destinationFileInformation, i, image, len, other, others, ref, source, sourceFileInformation, target;
  sourceFileInformation = informationOnFiles[file];
  source = sourceFileInformation.source;
  others = {};
  ref = config.sources;
  for (i = 0, len = ref.length; i < len; i++) {
    other = ref[i];
    destinationFileInformation = informationOnFiles[other];
    target = destinationFileInformation.destination;
    image = destinationFileInformation.language.name === 'image';
    others[target.base] = {
      link: getRelativePath(source.relativefile, target.relativefile, target.base),
      file: other,
      image: image
    };
  }
  return others;
};

module.exports = getOthers;

//# sourceMappingURL=getOthers.js.map
