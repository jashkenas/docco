# This tests if parse is working correctly.

    { assert, should } = require('chai'); should()
    parse = require '../../src/parse'

    describe 'docco parse', () ->

      it 'parse some source code', () ->
        code = require './fakes/fake_coffee'
        source = './fakes/fake_coffee'
        config =
          layout:     'parallel'
          output:     'docs'
          template:   null
          css:        null
          extension:  null
          languages:  {}
          marked:     null
          setup:      '.docco.json'
          help:      false
          flatten: false
        language = {"name":"coffeescript","symbol":"#","commentMatcher":{},"commentFilter":{}}

        sections = parse(source, language, code, config)
        console.log(JSON.stringify(sections,null,2))

