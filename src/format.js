var _, commander, format, fs, glob, highlightjs, marked, path;

_ = require('underscore');

fs = require('fs-extra');

path = require('path');

marked = require('marked');

commander = require('commander');

highlightjs = require('highlight.js');

path = require('path');

glob = require('glob');

module.exports = format = function(source, language, sections, config) {
  var code, i, j, len, markedOptions, results, section;
  markedOptions = {
    smartypants: true
  };
  if (config.marked) {
    markedOptions = config.marked;
  }
  marked.setOptions(markedOptions);
  marked.setOptions({
    highlight: function(code, lang) {
      lang || (lang = language.name);
      if (highlightjs.getLanguage(lang)) {
        return highlightjs.highlight(lang, code).value;
      } else {
        console.warn("docco: couldn't highlight code block with unknown language '" + lang + "' in " + source);
        return code;
      }
    }
  });
  results = [];
  for (i = j = 0, len = sections.length; j < len; i = ++j) {
    section = sections[i];
    if (language.html) {
      section.codeHtml = section.codeText;
    } else {
      code = highlightjs.highlight(language.name, section.codeText).value;
      code = code.replace(/\s+$/, '');
      section.codeHtml = "<div class='highlight'><pre>" + code + "</pre></div>";
    }
    results.push(section.docsHtml = marked(section.docsText));
  }
  return results;
};

//# sourceMappingURL=format.js.map
