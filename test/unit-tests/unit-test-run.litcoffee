# This tests if run is working correctly.

    { assert, should } = require('chai'); should()
    fixForMatch = require './utils/fixForMatch'
    mockery = require('mockery')
    mockery.enable({
      useCleanCache: true,
      warnOnReplace: false,
      warnOnUnregistered: false
    })
    times = 0
    mockery.registerMock('fs-extra', {
      existsSync: (file) ->

      readFileSync: (file) ->
        if times is 0
          times++
          return '{ "coffeescript": {"name":"coffeescript","symbol":"#"},' +
              ' ".markdown": {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true},' +
              ' ".md": {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true}}'
        else
          return '{  "version": "1.0.0" }'

    })
    mockery.registerMock('./src/document', (config) ->
      fakeConfig = require './fakes/fake-config'
      fakeConfig = fixForMatch(fakeConfig, ['path', 'pathdir','root'])
      config = fixForMatch(config, ['path', 'pathdir','root'])

      assert.deepEqual(config, fakeConfig)
    )
    mockery.registerMock('./src/configure', (commander, defaults, languages) ->
      commander.name.should.be.equal('docco')
      assert.deepEqual(languages, {
          ".markdown": {
            "html": true
            "link": "!"
            "name": "markdown"
            "section": "#"
            "symbol": ""
          }
          ".md": {
            "html": true
            "link": "!"
            "name": "markdown"
            "section": "#"
            "symbol": ""
          }
          "coffeescript": {
            "name": "coffeescript"
            "symbol": "#"
          }
      })
      assert.deepEqual(defaults, {
        "layout": "parallel",
        "output": "docs",
        "template": null,
        "css": null,
        "extension": null,
        "languages": {},
        "marked": null,
        "setup": ".docco.json",
        "help": false,
        "flatten": false
      })
      defaults.sources = [
        "README.md",
        "images/fluffybunny1.jpg"
      ]
      defaults.languages = languages
      defaults.css = 'docco.css'
      defaults.extension = '.md'
      return defaults
    )
    optionTimes = 0
    mockery.registerMock('commander', {
      version: (version) ->
        version.should.be.equal('1.0.0')
        return @
      usage: (usage) ->
        usage.should.be.equal('[options] [file]')
        return @
      option: (option, description, value) ->
        optionTimes++
        switch optionTimes
          when 1 then option.should.be.equal('-c, --css [file]')
          when 2 then option.should.be.equal('-e, --extension [ext]')
          when 3 then option.should.be.equal('-f, --flatten')
          when 4 then option.should.be.equal('-L, --languages [file]')
          when 5 then option.should.be.equal('-l, --layout [name]')
          when 6 then option.should.be.equal('-m, --marked [file]')
          when 7 then option.should.be.equal('-o, --output [path]')
          when 8 then option.should.be.equal('-s, --setup [file]')
          when 9 then option.should.be.equal('-t, --template [file]')
        return @
      parse: (args) ->
        assert.deepEqual(args, ["--flatten"])
        return @
      name: (name) ->
        name.should.be.equal('name')
        return @
    })
    { run } = require '../../docco'

    describe 'docco', () ->
      it 'handles parameters correctly', () ->
        run(["--flatten"])

      mockery.deregisterMock('./src/document')
