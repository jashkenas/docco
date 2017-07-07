# This tests if getLanguage is working correctly.

    { should } = require('chai'); should()
    getLanguage = require('../../src/getLanguage')
    {languages} = require('../../docco')

    describe 'docco getLanguage', () ->

      it 'gets the right language for the given a coffescript file.', () ->
        source = "src/fake_coffee.coffee"
        config = { languages:languages }
        language = getLanguage source, languages
        language.name.should.be.equal("coffeescript")
        language.symbol.should.be.equal("#")
        return

      it 'gets the right language for the given a markdown file.', () ->
        source = "README.md"
        config = { languages:languages }
        language = getLanguage source, languages
        language.name.should.be.equal("markdown")
        language.symbol.should.be.equal("")
        language.section.should.be.equal("#")
        language.link.should.be.equal("!")
        language.html.should.be.true
        return

      it 'gets the right language for the given an image file.', () ->
        source = "images/fluffybunny.jpg"
        config = { languages:languages }
        language = getLanguage source, languages
        language.name.should.be.equal("image")
        language.copy.should.be.true
        return
