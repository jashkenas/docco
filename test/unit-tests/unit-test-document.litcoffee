# This tests if document is working correctly.

    { assert, should } = require('chai'); should()
    mockery = require('mockery')
    mockery.enable({
      useCleanCache: true,
      warnOnReplace: false,
      warnOnUnregistered: false
    })
    times = 0
    mockery.registerMock('fs-extra', {
      mkdirs: (dir, callback) ->
        dir.should.be.equal('docs')
        callback()
        return
      mkdirsSync: (dir) ->
        if times is 0
          dir.should.be.equal(__dirname+'/docs/.')
        else
          dir.should.be.equal(__dirname+'/docs/images')

        times++
        return
      copy: (fromFile, toFile) ->
        fromFile.should.be.equal("images/fluffybunny1.jpg")
        toFile.should.be.equal(__dirname+"/docs/images/fluffybunny1.jpg")
        return
      existsSync: (dir) ->
        if times is 0
          dir.should.be.equal(__dirname+'/docs/.')
        else
          dir.should.be.equal(__dirname+'/docs/images')
        return
      readFile: (file, callback) ->
        file.should.be.equal('README.md')
        callback(null, "x=3")
        return
      readFileSync: () ->
        console.log("readFileSync:")
        return '{
            ".coffee":      {"name": "coffeescript", "symbol": "#"},
            ".litcoffee":   {"name": "coffeescript", "symbol": "#", "literate": true},
            ".md":          {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true}
          }'
      writeFileSync: (destination, html) ->
        console.log("writeFileSync:"+destination+ " html"+html)
        if flattened
          destination.should.be.equal("/Project/docs/fake_coffee.html")
          assert.equal(html,resultOfTemplateFlattened)
        else
          destination.should.be.equal("/Project/docs/src/fake_coffee.html")
          assert.equal(html,resultOfTemplateUnFlattened)
        return
    })

    mockery.registerMock('parse', (source, language, code, config = {}) ->
      console.log("PARSE::::")
    )
    mockery.registerMock('format', (source, language, sections, config) ->
      console.log("FORMAT::::")
    )
    mockery.registerMock('./write', (source, sections, config) ->
      source.should.be.equal("README.md")
      assert.deepEqual(sections, [
          {
            "docsText": "x=3\n",
            "codeText": "",
            "codeHtml": "",
            "docsHtml": "<p>x=3</p>\n"
          }
      ])
    )
    informationOnFiles = require('./fakes/informationOnFilesUnFlattened')

    document = require '../../src/document'

    describe 'docco document', () ->

      it 'document docco', () ->
        config =
          output:     'docs'
          sources: [
            "README.md",
            "images/fluffybunny1.jpg"
          ]
          root: __dirname
          informationOnFiles: informationOnFiles

        document(config)
        return
      return

    mockery.deregisterMock('./parse')
    mockery.deregisterMock('./format')
    mockery.deregisterMock('./write')
    mockery.deregisterMock('fs-extra')