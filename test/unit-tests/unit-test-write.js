var _, assert, flattened, informationOnFilesFlattened, informationOnFilesUnFlattened, languages, mockery, path, ref, resultOfTemplateFlattened, resultOfTemplateUnFlattened, should, template, write;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

mockery = require('mockery');

mockery.enable({
  useCleanCache: true,
  warnOnReplace: false,
  warnOnUnregistered: false
});

path = require('path');

_ = require('underscore');

resultOfTemplateFlattened = require('./fakes/fake-linear-jst-flattened-result');

resultOfTemplateUnFlattened = require('./fakes/fake-linear-jst-unflattened-result');

flattened = true;

mockery.registerMock('fs-extra', {
  readFileSync: function() {
    return '{ ".coffee":      {"name": "coffeescript", "symbol": "#"}, ".litcoffee":   {"name": "coffeescript", "symbol": "#", "literate": true}, ".md":          {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true} }';
  },
  writeFileSync: function(destination, html) {
    if (flattened) {
      destination.should.be.equal("/Project/docs/fake_coffee.html");
      return assert.equal(html, resultOfTemplateFlattened);
    } else {
      destination.should.be.equal("/Project/docs/src/fake_coffee.html");
      return assert.equal(html, resultOfTemplateUnFlattened);
    }
  }
});

write = require('../../src/write');

languages = require('../../docco').languages;

template = require('./fakes/fake-linear-jst');

informationOnFilesFlattened = require('./fakes/informationOnFilesFlattened');

informationOnFilesUnFlattened = require('./fakes/informationOnFilesUnFlattened');

describe('docco write', function() {
  it('writes to the correct flattened destination', function() {
    var config, result, sections, source;
    flattened = true;
    source = "src/fake_coffee.coffee";
    config = {
      css: "/Project/resources/linear/docco.css",
      languages: languages,
      output: 'docs',
      root: '/Project',
      css: 'docco.css',
      sources: ["src/fake_coffee.coffee", "README.md"],
      root: __dirname,
      informationOnFiles: informationOnFilesFlattened
    };
    config.template = _.template(template);
    sections = [
      {
        "docsText": "Some Doc Text",
        "codeText": "Some code Text",
        "codeHtml": "<div class='highlight'><pre>code=here;</pre></div>",
        "docsHtml": ""
      }
    ];
    result = write(source, sections, config);
  });
  it('writes to the correct unflattened destination', function() {
    var config, result, sections, source;
    flattened = false;
    source = "src/fake_coffee.coffee";
    config = {
      css: "/Project/resources/linear/docco.css",
      languages: languages,
      output: 'docs',
      root: '/Project',
      css: 'docco.css',
      sources: ["src/fake_coffee.coffee", "README.md"],
      root: __dirname,
      informationOnFiles: informationOnFilesUnFlattened
    };
    config.template = _.template(template);
    sections = [
      {
        "docsText": "Some Doc Text",
        "codeText": "Some code Text",
        "codeHtml": "<div class='highlight'><pre>code=here;</pre></div>",
        "docsHtml": ""
      }
    ];
    result = write(source, sections, config);
    mockery.deregisterMock('fs-extra');
  });
});

//# sourceMappingURL=unit-test-write.js.map
