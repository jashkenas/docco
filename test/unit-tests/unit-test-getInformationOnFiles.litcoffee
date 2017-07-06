# This tests if getDestinations is working correctly.

    { assert, should } = require('chai'); should()
    describe 'docco getInformationOnFiles', () ->
      { languages } = require('../../docco')
      getInformationOnFiles = require('../../src/getInformationOnFiles')

      it 'calculates file information with unflattened request', () ->
        informationOnFilesFake = require './fakes/informationOnFilesUnFlattened'
        source = "src/fake_coffee.coffee"
        config =
          languages:languages
          output: 'docs'
          root: '/Project'
          css: 'docco.css'
          sources: [
            "src/fake_coffee.coffee"
            "README.md"
            "images/fluffybunny1.jpg"
            "src/lib/fake_litcoffee.litcoffee"
          ]
        informationOnFiles = getInformationOnFiles(languages, config)
        assert.deepEqual(informationOnFiles, informationOnFilesFake)
        return

      it 'calculates file information with flattened request', () ->
        informationOnFilesFake = require './fakes/informationOnFilesFlattened'
        source = "src/fake_coffee.coffee"
        config =
          flatten: true
          languages:languages
          output: 'docs'
          root: '/Project'
          css: 'docco.css'
          sources: [
            "src/fake_coffee.coffee"
            "README.md"
            "images/fluffybunny1.jpg"
            "src/lib/fake_litcoffee.litcoffee"
          ]
          flatten: true
        informationOnFiles = getInformationOnFiles(languages, config)
        assert.deepEqual(informationOnFiles, informationOnFilesFake)
        return
