var buildMatchers;

module.exports = buildMatchers = function(languages) {
  var ext, l;
  for (ext in languages) {
    l = languages[ext];
    l.commentMatcher = RegExp("^\\s*" + l.symbol + "\\s?");
    l.commentFilter = /(^#![\/]|^\s*#\{)/;
    if (l.link) {
      l.linkMatcher = RegExp("^" + l.link + "\\[(.+)\\]\\((.+)\\)");
    }
    if (l.section) {
      l.sectionMatcher = RegExp("^" + l.section + "\\s?");
    }
  }
  return languages;
};

//# sourceMappingURL=buildMatchers.js.map
