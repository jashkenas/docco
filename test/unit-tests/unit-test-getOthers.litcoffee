# This tests if getLanguage is working correctly.

  { assert, should } = require('chai'); should()
  describe 'docco getOthers', () ->
    { getOthers } = require('../../docco')

    it 'gets paths to other destination files: top level, unflattened.', () ->
      informationOnFiles = require './fakes/informationOnFilesUnFlattened'
      config = {
        sources: [
          'README.md'
          'src/fake_coffee.coffee'
        ]
        flatten: false
      }
      others = getOthers('README.md', informationOnFiles, config)
      assert.deepEqual(others, {
        "README.html": "README.html"
        "fake_coffee.html": "src/fake_coffee.html"
      })
      return

    it 'gets paths to other destination files: 1 level down, unflattened.', () ->
      informationOnFiles = require './fakes/informationOnFilesUnFlattened'
      config = {
        sources: [
          'README.md'
          'src/fake_coffee.coffee'
        ]
        flatten: false
      }
      others = getOthers('src/fake_coffee.coffee', informationOnFiles, config)
      assert.deepEqual(others, {
        "README.html": "../README.html"
        "fake_coffee.html": "fake_coffee.html"
      })
      return

    it 'gets paths to other destination files: top level, flattened.', () ->
      informationOnFiles = require './fakes/informationOnFilesFlattened'
      config = {
        sources: [
          'README.md'
          'src/fake_coffee.coffee'
        ]
        flatten: true
      }
      others = getOthers('README.md', informationOnFiles, config)
      assert.deepEqual(others, {
        "README.html": "README.html"
        "fake_coffee.html": "fake_coffee.html"
      })
      return

    it 'gets paths to other destination files: 1 level down, flattened.', () ->
      informationOnFiles = require './fakes/informationOnFilesFlattened'
      config = {
        sources: [
          'README.md'
          'src/fake_coffee.coffee'
        ]
        flatten: true
      }
      others = getOthers('src/fake_coffee.coffee', informationOnFiles, config)
      assert.deepEqual(others, {
        "README.html": "README.html"
        "fake_coffee.html": "fake_coffee.html"
      })
      return