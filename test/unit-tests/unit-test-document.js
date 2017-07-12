var assert, document, informationOnFiles, mockery, ref, should, times;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

mockery = require('mockery');

mockery.enable({
  useCleanCache: true,
  warnOnReplace: false,
  warnOnUnregistered: false
});

times = 0;

mockery.registerMock('fs-extra', {
  mkdirs: function(dir, callback) {
    dir.should.be.equal('docs');
    callback();
  },
  mkdirsSync: function(dir) {
    if (times === 0) {
      dir.should.be.equal(__dirname + '/docs/.');
    } else {
      dir.should.be.equal(__dirname + '/docs/images');
    }
    times++;
  },
  copy: function(fromFile, toFile) {
    fromFile.should.be.equal("images/fluffybunny1.jpg");
    toFile.should.be.equal(__dirname + "/docs/images/fluffybunny1.jpg");
  },
  existsSync: function(dir) {
    if (times === 0) {
      dir.should.be.equal(__dirname + '/docs/.');
    } else {
      dir.should.be.equal(__dirname + '/docs/images');
    }
  },
  readFile: function(file, callback) {
    file.should.be.equal('README.md');
    callback(null, "x=3");
  },
  readFileSync: function() {
    return '{ ".coffee":      {"name": "coffeescript", "symbol": "#"}, ".litcoffee":   {"name": "coffeescript", "symbol": "#", "literate": true}, ".md":          {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true} }';
  },
  writeFileSync: function(destination, html) {
    if (flattened) {
      destination.should.be.equal("/Project/docs/fake_coffee.html");
      assert.equal(html, resultOfTemplateFlattened);
    } else {
      destination.should.be.equal("/Project/docs/src/fake_coffee.html");
      assert.equal(html, resultOfTemplateUnFlattened);
    }
  }
});

mockery.registerMock('parse', function(source, language, code, config) {
  if (config == null) {
    config = {};
  }
});

mockery.registerMock('format', function(source, language, sections, config) {});

mockery.registerMock('./write', function(source, sections, config) {
  source.should.be.equal("README.md");
  return assert.deepEqual(sections, [
    {
      "docsText": "x=3\n",
      "codeText": "",
      "codeHtml": "",
      "docsHtml": "<p>x=3</p>\n"
    }
  ]);
});

informationOnFiles = require('./fakes/informationOnFilesUnFlattened');

document = require('../../src/document');

describe('docco document', function() {
  it('document docco', function() {
    var config;
    config = {
      output: 'docs',
      sources: ["README.md", "images/fluffybunny1.jpg"],
      root: __dirname,
      informationOnFiles: informationOnFiles
    };
    document(config);
  });
});

mockery.deregisterMock('./parse');

mockery.deregisterMock('./format');

mockery.deregisterMock('./write');

mockery.deregisterMock('fs-extra');

//# sourceMappingURL=unit-test-document.js.map
