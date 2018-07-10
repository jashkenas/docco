var assert, fixForMatch, mockery, optionTimes, ref, run, should, times;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

fixForMatch = require('./utils/fixForMatch');

mockery = require('mockery');

mockery.enable({
  useCleanCache: true,
  warnOnReplace: false,
  warnOnUnregistered: false
});

times = 0;

mockery.registerMock('fs-extra', {
  existsSync: function(file) {},
  readFileSync: function(file) {
    if (times === 0) {
      times++;
      return '{ "coffeescript": {"name":"coffeescript","symbol":"#"},' + ' ".markdown": {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true},' + ' ".md": {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true}}';
    } else {
      return '{  "version": "1.0.0" }';
    }
  }
});

mockery.registerMock('./src/document', function(config) {
  var fakeConfig;
  fakeConfig = require('./fakes/fake-config');
  fakeConfig = fixForMatch(fakeConfig, ['path', 'pathdir', 'root']);
  config = fixForMatch(config, ['path', 'pathdir', 'root']);
  return assert.deepEqual(config, fakeConfig);
});

mockery.registerMock('./src/configure', function(commander, defaults, languages) {
  commander.name.should.be.equal('docco');
  assert.deepEqual(languages, {
    ".markdown": {
      "html": true,
      "link": "!",
      "name": "markdown",
      "section": "#",
      "symbol": ""
    },
    ".md": {
      "html": true,
      "link": "!",
      "name": "markdown",
      "section": "#",
      "symbol": ""
    },
    "coffeescript": {
      "name": "coffeescript",
      "symbol": "#"
    }
  });
  assert.deepEqual(defaults, {
    "layout": "sidebyside",
    "output": "docs",
    "template": null,
    "css": null,
    "extension": null,
    "languages": {},
    "marked": null,
    "setup": ".docco.json",
    "help": false,
    "flatten": false
  });
  defaults.sources = ["README.md", "images/fluffybunny1.jpg"];
  defaults.languages = languages;
  defaults.css = 'docco.css';
  defaults.extension = '.md';
  return defaults;
});

optionTimes = 0;

mockery.registerMock('commander', {
  version: function(version) {
    version.should.be.equal('1.0.0');
    return this;
  },
  usage: function(usage) {
    usage.should.be.equal('[options] [file]');
    return this;
  },
  option: function(option, description, value) {
    optionTimes++;
    switch (optionTimes) {
      case 1:
        option.should.be.equal('-c, --css [file]');
        break;
      case 2:
        option.should.be.equal('-e, --extension [ext]');
        break;
      case 3:
        option.should.be.equal('-f, --flatten');
        break;
      case 4:
        option.should.be.equal('-g, --languages [file]');
        break;
      case 5:
        option.should.be.equal('-l, --layout [name]');
        break;
      case 6:
        option.should.be.equal('-m, --marked [file]');
        break;
      case 7:
        option.should.be.equal('-o, --output [path]');
        break;
      case 8:
        option.should.be.equal('-s, --setup [file]');
        break;
      case 9:
        option.should.be.equal('-t, --template [file]');
    }
    return this;
  },
  parse: function(args) {
    assert.deepEqual(args, ["--flatten"]);
    return this;
  },
  name: function(name) {
    name.should.be.equal('name');
    return this;
  }
});

run = require('../../docco').run;

describe('docco', function() {
  it('handles parameters correctly', function() {
    return run(["--flatten"]);
  });
  return mockery.deregisterMock('./src/document');
});

//# sourceMappingURL=unit-test-run.js.map
