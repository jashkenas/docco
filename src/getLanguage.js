var getLanguage, path;

path = require('path');

getLanguage = function(source, languages, extension) {
  var codeExt, codeLang, ext, lang;
  ext = extension || path.extname(source) || path.basename(source);
  lang = languages[ext];
  if (lang && lang.name === 'markdown') {
    codeExt = path.extname(path.basename(source, ext));
    if (codeExt && (codeLang = languages[codeExt])) {
      lang = _.extend({}, codeLang, {
        literate: true
      });
    }
  }
  return lang;
};

module.exports = getLanguage;

//# sourceMappingURL=getLanguage.js.map
