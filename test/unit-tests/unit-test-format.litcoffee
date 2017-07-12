# This tests if parse is working correctly.

    { assert, should } = require('chai'); should()
    format = require '../../src/format'
    buildMatchers = require '../../src/buildMatchers'

    describe 'docco format', () ->

      it 'format docco', () ->

        source = 'fakes/fake_coffee.coffee'
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
        languages = [{"name":"coffeescript","symbol":"#","commentMatcher":{},"commentFilter":{}}]
        languages = buildMatchers languages

        sections = [
          {
            "docsText": "Assignment:\n",
            "codeText": "number   = 42\nopposite = true\n\n"
          },
          {
            "docsText": "Conditions:\n",
            "codeText": "number = -42 if opposite\n\n"
          },
          {
            "docsText": "Functions:\n",
            "codeText": "square = (x) -> x * x\n\n"
          }
        ]
        format(source, languages[0], sections, config)
        sections[0].docsText.should.be.equal("Assignment:\n")
        sections[0].codeText.should.be.equal("number   = 42\nopposite = true\n\n")
        sections[0].codeHtml.should.be.equal("<div class='highlight'><pre>number   = <span class=\"hljs-number\">42</span>\nopposite = <span class=\"hljs-literal\">true</span></pre></div>")
        sections[0].docsHtml.should.be.equal("<p>Assignment:</p>\n")

        sections[1].docsText.should.be.equal("Conditions:\n")
        sections[1].codeText.should.be.equal("number = -42 if opposite\n\n")
        sections[1].codeHtml.should.be.equal("<div class='highlight'><pre>number = <span class=\"hljs-number\">-42</span> <span class=\"hljs-keyword\">if</span> opposite</pre></div>")
        sections[1].docsHtml.should.be.equal("<p>Conditions:</p>\n")

        sections[2].docsText.should.be.equal("Functions:\n")
        sections[2].codeText.should.be.equal("square = (x) -> x * x\n\n")
        sections[2].codeHtml.should.be.equal("<div class='highlight'><pre><span class=\"hljs-function\"><span class=\"hljs-title\">square</span> = <span class=\"hljs-params\">(x)</span> -&gt;</span> x * x</pre></div>")
        sections[2].docsHtml.should.be.equal("<p>Functions:</p>\n")

        return
      return

