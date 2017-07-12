var assert, getDestinationInformation, getLanguage, languages, ref, should;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

languages = require('../../docco').languages;

getDestinationInformation = require('../../src/getDestinationInformation');

getLanguage = require('../../src/getLanguage');

describe('docco getDestinationInformation', function() {
  it('unflattened: gets destinationInformation for one source', function() {
    var config, destination, file, flatten, language, result, rootDirectory, source, targetDirectory;
    file = "src/fake_coffee.coffee";
    config = {
      languages: languages
    };
    language = getLanguage(file, languages);
    source = {
      "root": "/Project",
      "dir": "src",
      "base": "fake_coffee.coffee",
      "ext": ".coffee",
      "name": "fake_coffee",
      "file": "src/fake_coffee.coffee",
      "path": "/Project/src/fake_coffee.coffee"
    };
    rootDirectory = '/Project';
    targetDirectory = 'docs';
    flatten = false;
    destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten);
    result = {
      "root": "/Project",
      "dir": "docs/src",
      "ext": ".html",
      "base": "fake_coffee.html",
      "name": "fake_coffee",
      "file": "docs/src/fake_coffee.html",
      "path": "/Project/docs/src/fake_coffee.html",
      "pathdir": "/Project/docs/src",
      "relativefile": "src/fake_coffee.html"
    };
    assert.deepEqual(destination, result);
  });
  it('flattened: gets destinationInformation for one source', function() {
    var config, destination, file, flatten, language, result, rootDirectory, source, targetDirectory;
    file = "src/fake_coffee.coffee";
    config = {
      languages: languages
    };
    language = getLanguage(file, languages);
    source = {
      "root": "/Project",
      "dir": "src",
      "base": "fake_coffee.coffee",
      "ext": ".coffee",
      "name": "fake_coffee",
      "file": "src/fake_coffee.coffee",
      "path": "/Project/src/fake_coffee.coffee"
    };
    rootDirectory = '/Project';
    targetDirectory = 'docs';
    flatten = true;
    destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten);
    result = {
      "base": "fake_coffee.html",
      "dir": "docs",
      "ext": ".html",
      "file": "docs/fake_coffee.html",
      "name": "fake_coffee",
      "path": "/Project/docs/fake_coffee.html",
      "pathdir": "/Project/docs",
      "root": "/Project",
      "relativefile": "fake_coffee.html"
    };
    assert.deepEqual(destination, result);
  });
  it('unflattened: gets destinationInformation for one copy source', function() {
    var config, destination, file, flatten, language, result, rootDirectory, source, targetDirectory;
    file = "images/fluffybunny1.jpg";
    config = {
      languages: languages
    };
    language = getLanguage(file, languages);
    language.copy.should.be["true"];
    source = {
      "root": "/Project",
      "dir": "images",
      "base": "fluffybunny1.jpg",
      "ext": ".jpg",
      "name": "fluffybunny1",
      "file": "images/fluffybunny1.jpg",
      "path": "/Project/images/fluffybunny1.jpg"
    };
    rootDirectory = '/Project';
    targetDirectory = 'docs';
    flatten = false;
    destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten);
    result = {
      "root": "/Project",
      "dir": "docs/images",
      "base": "fluffybunny1.jpg",
      "ext": ".jpg",
      "name": "fluffybunny1",
      "file": "docs/images/fluffybunny1.jpg",
      "path": "/Project/docs/images/fluffybunny1.jpg",
      "pathdir": "/Project/docs/images",
      "relativefile": "images/fluffybunny1.jpg"
    };
    assert.deepEqual(destination, result);
  });
  it('flattened: gets destinationInformation for one copy source', function() {
    var config, destination, file, flatten, language, result, rootDirectory, source, targetDirectory;
    file = "images/fluffybunny1.jpg";
    config = {
      languages: languages
    };
    language = getLanguage(file, languages);
    language.copy.should.be["true"];
    source = {
      "root": "/Project",
      "dir": "images",
      "base": "fluffybunny1.jpg",
      "ext": ".jpg",
      "name": "fluffybunny1",
      "file": "images/fluffybunny1.jpg",
      "path": "/Project/images/fluffybunny1.jpg"
    };
    rootDirectory = '/Project';
    targetDirectory = 'docs';
    flatten = true;
    destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten);
    result = {
      "root": "/Project",
      "dir": "docs/images",
      "base": "fluffybunny1.jpg",
      "ext": ".jpg",
      "name": "fluffybunny1",
      "file": "docs/images/fluffybunny1.jpg",
      "path": "/Project/docs/images/fluffybunny1.jpg",
      "pathdir": "/Project/docs/images",
      "relativefile": "images/fluffybunny1.jpg"
    };
    assert.deepEqual(destination, result);
  });
});

//# sourceMappingURL=unit-test-getDestinationInformation.js.map
