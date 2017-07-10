var assert, getOthers, ref, should;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

getOthers = require('../../src/getOthers');

describe('docco getOthers', function() {
  it('gets paths to other destination files: top level, unflattened.', function() {
    var config, informationOnFiles, others;
    informationOnFiles = require('./fakes/informationOnFilesUnFlattened');
    config = {
      sources: ['README.md', 'src/fake_coffee.coffee'],
      flatten: false
    };
    others = getOthers('README.md', informationOnFiles, config);
    assert.deepEqual(others, {
      "README.html": "README.html",
      "fake_coffee.html": "src/fake_coffee.html"
    });
  });
  it('gets paths to other destination files: 1 level down, unflattened.', function() {
    var config, informationOnFiles, others;
    informationOnFiles = require('./fakes/informationOnFilesUnFlattened');
    config = {
      sources: ['README.md', 'src/fake_coffee.coffee'],
      flatten: false
    };
    others = getOthers('src/fake_coffee.coffee', informationOnFiles, config);
    assert.deepEqual(others, {
      "README.html": "../README.html",
      "fake_coffee.html": "fake_coffee.html"
    });
  });
  it('gets paths to other destination files: top level, flattened.', function() {
    var config, informationOnFiles, others;
    informationOnFiles = require('./fakes/informationOnFilesFlattened');
    config = {
      sources: ['README.md', 'src/fake_coffee.coffee'],
      flatten: true
    };
    others = getOthers('README.md', informationOnFiles, config);
    assert.deepEqual(others, {
      "README.html": "README.html",
      "fake_coffee.html": "fake_coffee.html"
    });
  });
  it('gets paths to other destination files: 1 level down, flattened.', function() {
    var config, informationOnFiles, others;
    informationOnFiles = require('./fakes/informationOnFilesFlattened');
    config = {
      sources: ['README.md', 'src/fake_coffee.coffee'],
      flatten: true
    };
    others = getOthers('src/fake_coffee.coffee', informationOnFiles, config);
    assert.deepEqual(others, {
      "README.html": "README.html",
      "fake_coffee.html": "fake_coffee.html"
    });
  });
});

//# sourceMappingURL=unit-test-getOthers.js.map
