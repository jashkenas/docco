# This tests if getDestinations is working correctly.

  #!/usr/bin/env node
  { assert, should } = require('chai'); should()
  describe 'docco getInformationOnFiles', () ->
    { languages, getInformationOnFiles } = require('../../docco')

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
      informationOnFiles = getInformationOnFiles(config)
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
      informationOnFiles = getInformationOnFiles(config)
      assert.deepEqual(informationOnFiles, informationOnFilesFake)
      return
