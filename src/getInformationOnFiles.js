var _, commander, fs, getCSSPath, getDestinationInformation, getInformationOnFiles, getLanguage, getOthers, getRelativePath, getSourceInformation, glob, highlightjs, marked, path;

_ = require('underscore');

fs = require('fs-extra');

path = require('path');

marked = require('marked');

commander = require('commander');

highlightjs = require('highlight.js');

path = require('path');

glob = require('glob');

getSourceInformation = require('./getSourceInformation');

getDestinationInformation = require('./getDestinationInformation');

getRelativePath = require('./getRelativePath');

getCSSPath = require('./getCSSPath');

getOthers = require('./getOthers');

getLanguage = require('./getLanguage');

module.exports = getInformationOnFiles = function(config) {
  var destination, destinations, file, i, informationOnFiles, j, language, len, len1, others, ref, ref1, rootDirectory, source, sourceDirectory, targetDirectory;
  targetDirectory = config.output;
  sourceDirectory = config.root;
  rootDirectory = config.root;
  informationOnFiles = {};
  ref = config.sources;
  for (i = 0, len = ref.length; i < len; i++) {
    file = ref[i];
    language = getLanguage(file, config.languages, config.extension);
    if (language == null) {
      language = getLanguage('not-supported', config.languages);
    }
    source = getSourceInformation(file, rootDirectory, config.flatten);
    destinations = {};
    destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, config.flatten);
    destination.css = getCSSPath(config.css, targetDirectory, destination.file);
    informationOnFiles[file] = {};
    informationOnFiles[file].destination = destination;
    informationOnFiles[file].source = source;
    informationOnFiles[file].language = language;
  }
  ref1 = config.sources;
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    file = ref1[j];
    others = getOthers(file, informationOnFiles, config);
    informationOnFiles[file].others = others;
  }
  return informationOnFiles;
};

//# sourceMappingURL=getInformationOnFiles.js.map
