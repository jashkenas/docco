var assert, buildMatchers, ref, should;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

buildMatchers = require('../../src/buildMatchers');

describe('docco getInformationOnFiles', function() {
  var getInformationOnFiles, languages;
  languages = require('../../docco').languages;
  getInformationOnFiles = require('../../src/getInformationOnFiles');
  it('calculates file information with unflattened request', function() {
    var config, informationOnFiles, informationOnFilesFake, source;
    informationOnFilesFake = require('./fakes/informationOnFilesUnFlattened');
    source = "src/fake_coffee.coffee";
    config = {
      output: 'docs',
      root: '/Project',
      css: 'docco.css',
      sources: ["src/fake_coffee.coffee", "README.md", "images/fluffybunny1.jpg", "src/lib/fake_litcoffee.litcoffee"]
    };
    config.languages = buildMatchers(languages);
    informationOnFiles = getInformationOnFiles(config);
    assert.deepEqual(informationOnFiles, informationOnFilesFake);
  });
  it('calculates file information with flattened request', function() {
    var config, informationOnFiles, informationOnFilesFake, source;
    informationOnFilesFake = require('./fakes/informationOnFilesFlattened');
    source = "src/fake_coffee.coffee";
    config = {
      flatten: true,
      languages: languages,
      output: 'docs',
      root: '/Project',
      css: 'docco.css',
      sources: ["src/fake_coffee.coffee", "README.md", "images/fluffybunny1.jpg", "src/lib/fake_litcoffee.litcoffee"],
      flatten: true
    };
    informationOnFiles = getInformationOnFiles(config);
    assert.deepEqual(informationOnFiles, informationOnFilesFake);
  });
});

//# sourceMappingURL=unit-test-getInformationOnFiles.js.map
