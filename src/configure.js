var _, buildMatchers, configure, fs, getLanguage, path,
  slice = [].slice;

_ = require('underscore');

fs = require('fs-extra');

path = require('path');

getLanguage = require('./getLanguage');

buildMatchers = require('./buildMatchers');

module.exports = configure = function(options, defaults, languages) {
  var config, dir;
  config = _.extend({}, defaults, _.pick.apply(_, [options].concat(slice.call(_.keys(defaults)))));
  config.languages = buildMatchers(languages);
  if (options.template) {
    if (!options.css) {
      console.warn("docco: no stylesheet file specified");
    }
    config.layout = null;
  } else {
    dir = config.layout = path.join(__dirname, '../resources', config.layout);
    if (fs.existsSync(path.join(dir, 'public'))) {
      config["public"] = path.join(dir, 'public');
    }
    config.template = path.join(dir, 'docco.jst');
    config.css = options.css || path.join(dir, 'docco.css');
  }
  config.template = _.template(fs.readFileSync(config.template).toString());
  if (options.marked) {
    config.marked = JSON.parse(fs.readFileSync(options.marked));
  }
  config.sources = options.args.filter(function(source) {
    var lang;
    lang = getLanguage(source, languages, config.extension);
    if (!lang) {
      console.warn("docco: skipped unknown type (" + (path.basename(source)) + ")");
    }
    return lang;
  }).sort();
  return config;
};

//# sourceMappingURL=configure.js.map
