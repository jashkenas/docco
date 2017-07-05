# This tests if getLanguage is working correctly.

  { assert, should } = require('chai'); should()
  { languages, getLanguage, getDestinationInformation } = require('../../docco')
  describe 'docco getDestinationInformation', () ->

    it 'unflattened: gets destinationInformation for one source', () ->
      file = "src/fake_coffee.coffee"
      config = { languages:languages }
      language = getLanguage file, config
      source = {
        "root":"/Project",
        "dir":"src",
        "base":"fake_coffee.coffee",
        "ext":".coffee",
        "name":"fake_coffee",
        "file":"src/fake_coffee.coffee",
        "path":"/Project/src/fake_coffee.coffee"
      }
      rootDirectory = '/Project'
      targetDirectory = 'docs'
      flatten = false
      destination = getDestinationInformation(languages, source, rootDirectory, targetDirectory, flatten)
      console.log(JSON.stringify(destination,null,2))
      result = {
        "root": "/Project",
        "dir": "docs/src",
        "ext": ".html",
        "base": "fake_coffee.html",
        "name": "fake_coffee",
        "file": "docs/src/fake_coffee.html",
        "path": "/Project/docs/src/fake_coffee.html",
        "pathdir": "/Project/docs/src"
      }
      assert.deepEqual(destination, result)
      return

    it 'flattened: gets destinationInformation for one source', () ->
      file = "src/fake_coffee.coffee"
      config = { languages:languages }
      language = getLanguage file, config
      source = {
        "root":"/Project",
        "dir":"src",
        "base":"fake_coffee.coffee",
        "ext":".coffee",
        "name":"fake_coffee",
        "file":"src/fake_coffee.coffee",
        "path":"/Project/src/fake_coffee.coffee"
      }
      rootDirectory = '/Project'
      targetDirectory = 'docs'
      flatten = true
      destination = getDestinationInformation(languages, source, rootDirectory, targetDirectory, flatten)
      console.log(JSON.stringify(destination,null,2))
      result = {
        "base": "fake_coffee.html"
        "dir": "docs"
        "ext": ".html"
        "file": "docs/fake_coffee.html"
        "name": "fake_coffee"
        "path": "/Project/docs/fake_coffee.html"
        "pathdir": "/Project/docs"
        "root": "/Project"
      }
      assert.deepEqual(destination, result)
      return