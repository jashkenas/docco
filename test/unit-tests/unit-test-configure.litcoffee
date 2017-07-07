# This tests if parse is working correctly.

    _ = require 'underscore'
    { assert, should } = require('chai'); should()
    commander   = require 'commander'
    configure = require '../../src/configure'
    version = "0.0.0"
    fs = {
      readFileSync: () ->
        return
    }

    describe 'docco configure', () ->

      it 'configure docco', () ->

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
        args = [
          "bin/node",
          "bin/docco",
          "--setup=.adocco.json"
        ]
        defaults =
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

        commander.version(version)
          .usage('[options] [file]')
          .option('-c, --css [file]',       'use a custom css file', config.css)
          .option('-e, --extension [ext]',  'assume a file extension for all inputs', config.extension)
          .option('-f, --flatten',          'flatten the directory hierarchy', config.flatten)
          .option('-L, --languages [file]', 'use a custom languages.json', _.compose JSON.parse, fs.readFileSync)
          .option('-l, --layout [name]',    'choose a layout (parallel, linear or classic)', config.layout)
          .option('-m, --marked [file]',    'use custom marked options', config.marked)
          .option('-o, --output [path]',    'output to a given folder', config.output)
          .option('-s, --setup [file]',     'use configuration file, normally docco.json', '.docco.json')
          .option('-t, --template [file]',  'use a custom .jst template', config.template)
          .parse(args)
          .name = "docco"

        config = configure commander, defaults

        config.css.should.be.equal("/Users/rolov/Code/docco/resources/parallel/docco.css")
        config.flatten.should.be.equal(false)
        config.layout.should.be.equal("/Users/rolov/Code/docco/resources/parallel")
        config.output.should.be.equal("docs")
        config.public.should.be.equal("/Users/rolov/Code/docco/resources/parallel/public")
        config.setup.should.be.equal(".adocco.json")
        config.sources.length.should.be.equal(0)
        config.template.should.be.ok

        return
      return
