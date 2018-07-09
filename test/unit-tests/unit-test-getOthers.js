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
      "README.html": {
        "file": "README.md",
        "image": false,
        "link": "README.html"
      },
      "fake_coffee.html": {
        "file": "src/fake_coffee.coffee",
        "image": false,
        "link": "src/fake_coffee.html"
      }
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
      "README.html": {
        "file": "README.md",
        "image": false,
        "link": "../README.html"
      },
      "fake_coffee.html": {
        "file": "src/fake_coffee.coffee",
        "image": false,
        "link": "fake_coffee.html"
      }
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
      "README.html": {
        "file": "README.md",
        "image": false,
        "link": "README.html"
      },
      "fake_coffee.html": {
        "file": "src/fake_coffee.coffee",
        "image": false,
        "link": "fake_coffee.html"
      }
    });
  });
  it('gets paths to other destination files: 1 level down, flattened.', function() {
    var config, informationOnFiles, others;
    informationOnFiles = require('./fakes/informationOnFilesFlattened');
    config = {
      sources: ['README.md', 'images/fluffybunny1.jpg'],
      flatten: true
    };
    others = getOthers('images/fluffybunny1.jpg', informationOnFiles, config);
    assert.deepEqual(others, {
      "README.html": {
        "file": "README.md",
        "image": false,
        "link": "README.html"
      },
      "fluffybunny1.jpg": {
        "file": "images/fluffybunny1.jpg",
        "image": true,
        "link": "images/fluffybunny1.jpg"
      }
    });
  });
});

//# sourceMappingURL=unit-test-getOthers.js.map
