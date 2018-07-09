var buildMatchers;

module.exports = buildMatchers = function(languages) {
  var ext, l, start, stop;
  for (ext in languages) {
    l = languages[ext];
    l.commentMatcher = RegExp("^\\s*" + l.symbol + "\\s?");
    l.commentFilter = /(^#![\/]|^\s*#\{)/;
    if (l.link) {
      l.imageMatcher = RegExp("^" + l.link + "\\[(.+)\\]\\((.+)\\)");
      l.linkMatcher = /^\[(.+)\]\((.+)\)/;
    }
    if (l.section) {
      l.sectionMatcher = RegExp("^" + l.section + "\\s?");
    }
    if (l.multiline) {
      start = l.multiline.start.replace(/(.{1})/g, "\\$1");
      stop = l.multiline.stop.replace(/(.{1})/g, "\\$1");
      l.startMatcher = RegExp("^\\s*" + start);
      l.stopMatcher = RegExp("^\\s*" + stop);
    }
    if (l.code) {
      l.code = l.code.replace(/(.{1})/g, "\\$1");
      l.codeMatcher = RegExp("^\\s*" + l.code);
    }
  }
  return languages;
};

//# sourceMappingURL=buildMatchers.js.map
