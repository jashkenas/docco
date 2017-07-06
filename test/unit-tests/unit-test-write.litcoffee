# This tests if write is working correctly.

    { assert, should } = require('chai'); should()

    mockery = require('mockery')
    mockery.enable({
      useCleanCache: true,
      warnOnReplace: false,
      warnOnUnregistered: false
    })

    path = require('path')
    _ = require 'underscore'


    resultOfTemplateFlattened = require './fakes/fake-linear-jst-flattened-result'
    resultOfTemplateUnFlattened = require './fakes/fake-linear-jst-unflattened-result'
    flattened = true
    mockery.registerMock('fs-extra', {
      readFileSync: () ->
        return '{
          ".coffee":      {"name": "coffeescript", "symbol": "#"},
          ".litcoffee":   {"name": "coffeescript", "symbol": "#", "literate": true},
          ".md":          {"name": "markdown", "symbol": "", "section": "#", "link": "!", "html": true}
        }'
      writeFileSync: (destination, html) ->
        if flattened
          destination.should.be.equal("/Project/docs/fake_coffee.html")
          assert.equal(html,resultOfTemplateFlattened)
        else
          destination.should.be.equal("/Project/docs/src/fake_coffee.html")
          assert.equal(html,resultOfTemplateUnFlattened)
    })

    write = require '../../src/write'
    { languages } = require('../../docco')

    template = require './fakes/fake-linear-jst'
    informationOnFilesFlattened = require './fakes/informationOnFilesFlattened'
    informationOnFilesUnFlattened = require './fakes/informationOnFilesUnFlattened'

    describe 'docco write', () ->

      it 'writes to the correct flattened destination', () ->
        flattened = true

        source = "src/fake_coffee.coffee"
        config =
          css: "/Project/resources/linear/docco.css"
          languages:languages
          output: 'docs'
          root: '/Project'
          css: 'docco.css'
          sources: [
            "src/fake_coffee.coffee"
            "README.md"
          ]
          root: __dirname
          informationOnFiles: informationOnFilesFlattened

        config.template = _.template template

        sections = [{
          "docsText":"Some Doc Text",
          "codeText":"Some code Text",
          "codeHtml":"<div class='highlight'><pre>code=here;</pre></div>",
          "docsHtml":""}]
        result = write(source, sections, config)
        return

      it 'writes to the correct unflattened destination', () ->
        flattened = false

        source = "src/fake_coffee.coffee"
        config =
          css: "/Project/resources/linear/docco.css"
          languages:languages
          output: 'docs'
          root: '/Project'
          css: 'docco.css'
          sources: [
            "src/fake_coffee.coffee"
            "README.md"
          ]
          root: __dirname
          informationOnFiles: informationOnFilesUnFlattened

        config.template = _.template template

        sections = [{
          "docsText":"Some Doc Text",
          "codeText":"Some code Text",
          "codeHtml":"<div class='highlight'><pre>code=here;</pre></div>",
          "docsHtml":""}]
        result = write(source, sections, config)
        mockery.deregisterMock('fs-extra')

        return

      return