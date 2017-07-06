# This tests if getLanguage is working correctly.

    { assert, should } = require('chai'); should()
    describe 'docco getDestinationInformation', () ->
      { languages, getLanguage, getDestinationInformation } = require('../../docco')

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
        destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten)
        console.log(JSON.stringify(destination,null,2))
        result = {
          "root": "/Project",
          "dir": "docs/src",
          "ext": ".html",
          "base": "fake_coffee.html",
          "name": "fake_coffee",
          "file": "docs/src/fake_coffee.html",
          "path": "/Project/docs/src/fake_coffee.html",
          "pathdir": "/Project/docs/src",
          "relativefile": "src/fake_coffee.html"
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
        destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten)
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
          "relativefile": "fake_coffee.html"
        }
        assert.deepEqual(destination, result)
        return

      it 'unflattened: gets destinationInformation for one copy source', () ->
        file = "images/fluffybunny1.jpg"
        config = { languages:languages }
        language = getLanguage file, config
        language.copy.should.be.true

        source = {
          "root":"/Project",
          "dir":"images",
          "base":"fluffybunny1.jpg",
          "ext":".jpg",
          "name":"fluffybunny1",
          "file":"images/fluffybunny1.jpg",
          "path":"/Project/images/fluffybunny1.jpg"
        }
        rootDirectory = '/Project'
        targetDirectory = 'docs'
        flatten = false
        destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten)
        console.log(JSON.stringify(destination,null,2))
        result = {
          "root": "/Project",
          "dir": "docs/images",
          "base": "fluffybunny1.jpg",
          "ext": ".jpg",
          "name": "fluffybunny1",
          "file": "docs/images/fluffybunny1.jpg",
          "path": "/Project/docs/images/fluffybunny1.jpg",
          "pathdir": "/Project/docs/images",
          "relativefile": "images/fluffybunny1.jpg"
        }
        assert.deepEqual(destination, result)
        return

      it 'flattened: gets destinationInformation for one copy source', () ->
        file = "images/fluffybunny1.jpg"
        config = { languages:languages }
        language = getLanguage file, config
        language.copy.should.be.true
        source = {
          "root":"/Project",
          "dir":"images",
          "base":"fluffybunny1.jpg",
          "ext":".jpg",
          "name":"fluffybunny1",
          "file":"images/fluffybunny1.jpg",
          "path":"/Project/images/fluffybunny1.jpg"
        }
        rootDirectory = '/Project'
        targetDirectory = 'docs'
        flatten = true
        destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, flatten)
        console.log(JSON.stringify(destination,null,2))
        result = {
          "root": "/Project"
          "dir": "docs/images"
          "base": "fluffybunny1.jpg"
          "ext": ".jpg"
          "name": "fluffybunny1"
          "file": "docs/images/fluffybunny1.jpg"
          "path": "/Project/docs/images/fluffybunny1.jpg"
          "pathdir": "/Project/docs/images"
          "relativefile": "images/fluffybunny1.jpg"
        }
        assert.deepEqual(destination, result)
        return