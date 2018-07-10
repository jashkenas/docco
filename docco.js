var Docco, _, commander, configure, defaults, document, format, fs, getInformationOnFiles, glob, highlightjs, languages, marked, parse, path, run, version;

document = require('./src/document');

parse = require('./src/parse');

format = require('./src/format');

configure = require('./src/configure');

getInformationOnFiles = require('./src/getInformationOnFiles');

_ = require('underscore');

fs = require('fs-extra');

path = require('path');

marked = require('marked');

commander = require('commander');

highlightjs = require('highlight.js');

path = require('path');

glob = require('glob');

languages = JSON.parse(fs.readFileSync(path.join(__dirname, 'resources', 'languages.json')));

version = JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'))).version;

defaults = {
  layout: 'sidebyside',
  output: 'docs',
  template: null,
  css: null,
  extension: null,
  languages: {},
  marked: null,
  setup: '.docco.json',
  help: false,
  flatten: false
};

run = function(args) {
  var config, file, files, globName, i, j, len, len1, ref, setup;
  if (args == null) {
    args = process.argv;
  }
  config = defaults;
  commander.version(version).usage('[options] [file]').option('-c, --css [file]', 'use a custom css file', config.css).option('-e, --extension [ext]', 'assume a file extension for all inputs', config.extension).option('-f, --flatten', 'flatten the directory hierarchy', config.flatten).option('-g, --languages [file]', 'use a custom languages.json', _.compose(JSON.parse, fs.readFileSync)).option('-l, --layout [name]', 'choose a layout (parallel, linear or classic)', config.layout).option('-m, --marked [file]', 'use custom marked options', config.marked).option('-o, --output [path]', 'output to a given folder', config.output).option('-s, --setup [file]', 'use configuration file, normally docco.json', '.docco.json').option('-t, --template [file]', 'use a custom .jst template', config.template).parse(args).name = "docco";
  config = configure(commander, defaults, languages);
  setup = path.resolve(config.setup);
  if (fs.existsSync(setup)) {
    if (setup) {
      config = _.extend(config, JSON.parse(fs.readFileSync(setup)));
    }
  }
  config.root = process.cwd();
  if (config.sources.length !== 0) {
    files = [];
    ref = config.sources;
    for (i = 0, len = ref.length; i < len; i++) {
      globName = ref[i];
      files = _.flatten(_.union(files, glob.sync(path.resolve(config.root, globName))));
      if (files.length === 0) {
        files.push(globName);
      }
    }
    config.sources = [];
    for (j = 0, len1 = files.length; j < len1; j++) {
      file = files[j];
      config.sources.push(path.relative(config.root, file));
    }
    config.informationOnFiles = getInformationOnFiles(config);
    document(config);
  } else {
    console.log(commander.helpInformation());
  }
};

module.exports = Docco = {
  run: run,
  document: document,
  parse: parse,
  format: format,
  languages: languages,
  version: version
};

//# sourceMappingURL=docco.js.map
