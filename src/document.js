var _, commander, document, format, fs, getLanguage, glob, highlightjs, marked, parse, path, write;

_ = require('underscore');

fs = require('fs-extra');

path = require('path');

marked = require('marked');

commander = require('commander');

highlightjs = require('highlight.js');

path = require('path');

glob = require('glob');

getLanguage = require('./getLanguage');

parse = require('./parse');

format = require('./format');

write = require('./write');

document = function(config, callback) {
  if (config == null) {
    config = {};
  }
  fs.mkdirs(config.output, function() {
    var complete, copyAsset, files, nextFile;
    callback || (callback = function(error) {
      if (error) {
        throw error;
      }
    });
    copyAsset = function(file, callback) {
      if (!fs.existsSync(file)) {
        return callback();
      }
      return fs.copy(file, path.join(config.output, path.basename(file)), callback);
    };
    complete = function() {
      return copyAsset(config.css, function(error) {
        if (error) {
          return callback(error);
        }
        if (fs.existsSync(config["public"])) {
          return copyAsset(config["public"], callback);
        }
        return callback();
      });
    };
    files = config.sources.slice();
    nextFile = function() {
      var language, source, toDirectory, toFile;
      source = files.shift();
      language = config.informationOnFiles[source].language;
      if (config.flatten && !language.copy) {
        toDirectory = config.output;
      } else {
        toDirectory = config.root + '/' + config.output + '/' + (path.dirname(source));
      }
      if (!fs.existsSync(toDirectory)) {
        fs.mkdirsSync(toDirectory);
      }
      if (language.copy) {
        toFile = toDirectory + '/' + path.basename(source);
        console.log("docco: " + source + " -> " + toFile);
        return fs.copy(source, toFile, function(error, result) {
          if (error) {
            return callback(error);
          }
          if (files.length) {
            return nextFile();
          } else {
            return complete();
          }
        });
      } else {
        return fs.readFile(source, function(error, buffer) {
          var code, sections;
          if (error) {
            return callback(error);
          }
          code = buffer.toString();
          sections = parse(source, language, code, config);
          format(source, language, sections, config);
          toFile = toDirectory + '/' + (path.basename(source, path.extname(source)));
          write(source, sections, config);
          if (files.length) {
            return nextFile();
          } else {
            return complete();
          }
        });
      }
    };
    return nextFile();
  });
};

module.exports = document;

//# sourceMappingURL=document.js.map
