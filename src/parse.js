// Generated by CoffeeScript 2.0.0-beta3
(function() {
  var _, commander, fs, glob, highlightjs, htmlImageMatcher, marked, parse, path;

  _ = require('underscore');

  fs = require('fs-extra');

  path = require('path');

  marked = require('marked');

  commander = require('commander');

  highlightjs = require('highlight.js');

  path = require('path');

  glob = require('glob');

  htmlImageMatcher = /^<img .*\/>/;

  module.exports = parse = function(source, language, code, config = {}) {
    var LINK_REGEX, STYLE_REGEX, TEXT_REGEX, codeText, docsText, hasCode, i, isText, j, k, len, len1, line, lines, link, links, match, maybeCode, save, sections, style, text, texts;
    lines = code.split('\n');
    sections = [];
    hasCode = docsText = codeText = '';
    save = function() {
      sections.push({docsText, codeText});
      hasCode = docsText = codeText = '';
    };
    if (language.literate) {
      isText = maybeCode = true;
      for (i = j = 0, len = lines.length; j < len; i = ++j) {
        line = lines[i];
        lines[i] = maybeCode && (match = /^([ ]{4}|[ ]{0,3}\t)/.exec(line)) ? (isText = false, line.slice(match[0].length)) : (maybeCode = /^\s*$/.test(line)) ? isText ? language.symbol : '' : (isText = true, language.symbol + ' ' + line);
      }
    }
    for (k = 0, len1 = lines.length; k < len1; k++) {
      line = lines[k];
      if (language.linkMatcher && line.match(language.linkMatcher)) {
        LINK_REGEX = /\((.+)\)/;
        TEXT_REGEX = /\[(.+)\]/;
        STYLE_REGEX = /\{(.+)\}/;
        links = LINK_REGEX.exec(line);
        texts = TEXT_REGEX.exec(line);
        style = STYLE_REGEX.exec(line);
        if ((links != null) && links.length > 1 && (texts != null) && texts.length > 1) {
          link = links[1];
          text = texts[1];
          style = style[1];
          console.log("STYLE:" + JSON.stringify(style));
          codeText += '<div><img src="' + link + '" style="' + style + '"></img><p>' + text + '</p></div>' + '\n';
        }
        hasCode = true;
      } else if (line.match(htmlImageMatcher)) {
        codeText += line;
        hasCode = true;
      } else if (language.sectionMatcher && line.match(language.sectionMatcher)) {
        if (hasCode) {
          save();
        }
        docsText += (line = line.replace(language.commentMatcher, '')) + '\n';
        save();
      } else if (line.match(language.commentMatcher) && !line.match(language.commentFilter)) {
        if (hasCode) {
          save();
        }
        docsText += (line = line.replace(language.commentMatcher, '')) + '\n';
        if (/^(---+|===+)$/.test(line)) {
          save();
        }
      } else {
        hasCode = true;
        codeText += line + '\n';
      }
    }
    save();
    return sections;
  };

}).call(this);

//# sourceMappingURL=parse.js.map