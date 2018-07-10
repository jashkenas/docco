var getLanguage, languages, should;

should = require('chai').should;

should();

getLanguage = require('../../src/getLanguage');

languages = require('../../docco').languages;

describe('docco getLanguage', function() {
  it('gets the right language for the given a coffescript file.', function() {
    var config, language, source;
    source = "src/fake_coffee.coffee";
    config = {
      languages: languages
    };
    language = getLanguage(source, languages);
    language.name.should.be.equal("coffeescript");
    language.symbol.should.be.equal("#");
  });
  it('gets the right language for the given a markdown file.', function() {
    var config, language, source;
    source = "README.md";
    config = {
      languages: languages
    };
    language = getLanguage(source, languages);
    language.name.should.be.equal("markdown");
    language.symbol.should.be.equal("");
    language.section.should.be.equal("#");
    language.link.should.be.equal("!");
    language.html.should.be["true"];
  });
  it('gets the right language for the given an image file.', function() {
    var config, language, source;
    source = "images/fluffybunny.jpg";
    config = {
      languages: languages
    };
    language = getLanguage(source, languages);
    language.name.should.be.equal("image");
    language.copy.should.be["true"];
  });
});

//# sourceMappingURL=unit-test-getLanguage.js.map
