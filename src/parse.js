var Handlebars, _, commander, fs, glob, highlightjs, hrefLinkTemplate, htmlImageMatcher, imageLinkTemplate, marked, parse, path;

_ = require('underscore');

fs = require('fs-extra');

path = require('path');

marked = require('marked');

commander = require('commander');

Handlebars = require('handlebars');

highlightjs = require('highlight.js');

path = require('path');

glob = require('glob');

htmlImageMatcher = /^<img .*\/>/;

imageLinkTemplate = Handlebars.compile('<div><img src="{{link}}" style="{{style}}"></img><p>{{text}}</p></div>\n');

hrefLinkTemplate = Handlebars.compile('<div><a href="{{link}}" style="{{style}}">{{text}}</a></div>\n');

module.exports = parse = function(source, language, code, config) {
  var codeText, docsText, getLinkComponents, hasCode, i, isText, j, k, len, len1, line, lines, makeLink, match, maybeCode, multilineComment, parts, save, sections, text, textToCode;
  if (config == null) {
    config = {};
  }
  lines = code.split('\n');
  sections = [];
  hasCode = docsText = codeText = '';
  save = function() {
    sections.push({
      docsText: docsText,
      codeText: codeText
    });
    hasCode = docsText = codeText = '';
  };
  if (language.literate) {
    isText = maybeCode = true;
    for (i = j = 0, len = lines.length; j < len; i = ++j) {
      line = lines[i];
      lines[i] = maybeCode && (match = /^([ ]{4}|[ ]{0,3}\t)/.exec(line)) ? (isText = false, line.slice(match[0].length)) : (maybeCode = /^\s*$/.test(line)) ? isText ? language.symbol : '' : (isText = true, language.symbol + ' ' + line);
    }
  }
  getLinkComponents = function(line, matcher) {
    var LINK_REGEX, STYLE_REGEX, TEXT_REGEX, link, links, style, styles, text, texts;
    LINK_REGEX = /\((.+?)\)/;
    TEXT_REGEX = /\[(.+?)\]/;
    STYLE_REGEX = /\{(.+?)\}/;
    links = LINK_REGEX.exec(line);
    texts = TEXT_REGEX.exec(line);
    styles = STYLE_REGEX.exec(line);
    if ((links != null) && links.length > 0 && (texts != null) && texts.length > 1) {
      link = links[1];
      if (texts && texts.length > 0) {
        text = texts[1];
      } else {
        text = '';
      }
      if (styles && styles.length > 0) {
        style = styles[1];
      } else {
        style = '';
      }
      return {
        link: link,
        text: text,
        style: style
      };
    } else {
      return null;
    }
  };
  makeLink = function(line, parts, template) {
    return template(parts);
  };
  for (k = 0, len1 = lines.length; k < len1; k++) {
    line = lines[k];
    if (language.imageMatcher && line.match(language.imageMatcher)) {
      parts = getLinkComponents(line, language.imageMatcher);
      if (parts != null) {
        codeText += imageLinkTemplate(parts);
      }
      hasCode = true;
    } else if (language.linkMatcher && line.match(language.linkMatcher)) {
      parts = getLinkComponents(line, language.linkMatcher);
      if (parts != null) {
        codeText += hrefLinkTemplate(parts);
      }
      hasCode = true;
    } else if (line.match(htmlImageMatcher)) {
      codeText += line + '\n';
      hasCode = true;
    } else if (multilineComment && (language.stopMatcher && line.match(language.stopMatcher))) {
      multilineComment = false;
      docsText += (line = line.replace(language.stopMatcher, '')) + '\n';
      hasCode = true;
    } else if (multilineComment || (language.startMatcher && line.match(language.startMatcher))) {
      multilineComment = true;
      if (hasCode) {
        save();
      }
      docsText += (line = line.replace(language.startMatcher, '')) + '\n';
    } else if (textToCode && (language.codeMatcher && line.match(language.codeMatcher))) {
      textToCode = false;
      text = (line = line.replace(language.codeMatcher, '')) + '\n';
      if (language.html) {
        text += "</pre>";
      }
      if (hasCode) {
        save();
      }
      codeText += text;
    } else if (textToCode || (language.codeMatcher && line.match(language.codeMatcher))) {
      textToCode = true;
      hasCode = true;
      if (language.html) {
        text = "<pre>";
      } else {
        text = "";
      }
      text += (line = line.replace(language.codeMatcher, '')) + '\n';
      codeText += text;
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

//# sourceMappingURL=parse.js.map
