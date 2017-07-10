// Generated by CoffeeScript 1.12.6
(function() {
  var _, commander, fs, glob, highlightjs, marked, path, write;

  _ = require('underscore');

  fs = require('fs-extra');

  path = require('path');

  marked = require('marked');

  commander = require('commander');

  highlightjs = require('highlight.js');

  path = require('path');

  glob = require('glob');

  module.exports = write = function(source, sections, config) {
    var destination, fileInfo, first, firstSection, hasTitle, html, objectValues, others, title;
    destination = function(file) {
      return file;
    };
    objectValues = function(obj) {
      return Object.keys(obj).map(function(key) {
        return obj[key];
      });
    };
    firstSection = _.find(sections, function(section) {
      return section.docsText.length > 0;
    });
    if (firstSection) {
      first = marked.lexer(firstSection.docsText)[0];
    }
    hasTitle = first && first.type === 'heading' && first.depth === 1;
    title = hasTitle ? first.text : path.basename(source);
    fileInfo = config.informationOnFiles[source];
    others = objectValues(fileInfo.others);
    html = config.template({
      sources: others,
      css: fileInfo.destination.css,
      title: title,
      hasTitle: hasTitle,
      sections: sections,
      path: path,
      destination: destination
    });
    console.log("docco: " + source + " -> " + (destination(fileInfo.destination.path)));
    fs.writeFileSync(destination(fileInfo.destination.path), html);
  };

}).call(this);