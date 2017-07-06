# This tests if parse is working correctly.

    { assert, should } = require('chai'); should()
    parse = require '../../src/parse'

    describe 'docco parse', () ->

      it 'parse some source code', () ->
        source = require './fakes/fake_coffee.coffee'

        sections = parse(source, code, config)

