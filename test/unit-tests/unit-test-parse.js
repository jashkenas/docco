var assert, buildMatchers, fs, parse, ref, should;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

fs = require('fs-extra');

parse = require('../../src/parse');

buildMatchers = require('../../src/buildMatchers');

describe('docco parse', function() {
  it('parse a file into sections of code and text', function() {
    var code, config, languages, sections, source;
    code = fs.readFileSync(__dirname + '/fakes/fake_coffee.coffee').toString();
    source = 'fakes/fake_coffee.coffee';
    config = {
      layout: 'parallel',
      output: 'docs',
      template: null,
      css: null,
      extension: null,
      languages: {},
      marked: null,
      setup: '.docco.json',
      help: false,
      flatten: false
    };
    languages = [
      {
        "name": "coffeescript",
        "symbol": "#",
        "commentMatcher": {},
        "commentFilter": {}
      }
    ];
    languages = buildMatchers(languages);
    sections = parse(source, languages[0], code, config);
    sections[0].docsText.should.be.equal("Assignment:\n");
    sections[0].codeText.should.be.equal("number   = 42\nopposite = true\n\n");
    sections[1].docsText.should.be.equal("Conditions:\n");
    sections[1].codeText.should.be.equal("number = -42 if opposite\n\n");
    sections[2].docsText.should.be.equal("Functions:\n");
    sections[2].codeText.should.be.equal("square = (x) -> x * x\n\n");
  });
});

//# sourceMappingURL=unit-test-parse.js.map
