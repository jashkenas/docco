Docco
=====

**Docco** is a quick-and-dirty documentation generator, written in
[Literate CoffeeScript](http://coffeescript.org/#literate).
It produces an HTML document that displays your comments intermingled with your
code. All prose is passed through
[Markdown](http://daringfireball.net/projects/markdown/syntax), and code is
passed through [Highlight.js](http://highlightjs.org/) syntax highlighting.
This page is the result of running Docco against its own
[source file](https://github.com/jashkenas/docco/blob/master/docco.litcoffee).

1. Install Docco with **npm**: `sudo npm install -g docco`

2. Run it against your code: `docco src/*.coffee`

There is no "Step 3". This will generate an HTML page for each of the named
source files, with a menu linking to the other pages, saving the whole mess
into a `docs` folder (configurable).

The [Docco source](http://github.com/jashkenas/docco) is available on GitHub,
and is released under the [MIT license](http://opensource.org/licenses/MIT).

Docco can be used to process code written in any programming language. If it
doesn't handle your favorite yet, feel free to
[add it to the list](https://github.com/jashkenas/docco/blob/master/resources/languages.json).
Finally, the ["literate" style](http://coffeescript.org/#literate) of *any*
language is also supported — just tack an `.md` extension on the end:
`.coffee.md`, `.py.md`, and so on.


Partners in Crime:
------------------

* If Node.js doesn't run on your platform, or you'd prefer a more
convenient package, get [Ryan Tomayko](http://github.com/rtomayko)'s
[Rocco](http://rtomayko.github.io/rocco/rocco.html), the **Ruby** port that's
available as a gem.

* If you're writing shell scripts, try
[Shocco](http://rtomayko.github.io/shocco/), a port for the **POSIX shell**,
also by Mr. Tomayko.

* If **Python** is more your speed, take a look at
[Nick Fitzgerald](http://github.com/fitzgen)'s [Pycco](https://pycco-docs.github.io/pycco/).

* For **Clojure** fans, [Fogus](http://blog.fogus.me/)'s
[Marginalia](http://fogus.me/fun/marginalia/) is a bit of a departure from
"quick-and-dirty", but it'll get the job done.

* There's a **Go** port called [Gocco](http://nikhilm.github.io/gocco/),
written by [Nikhil Marathe](https://github.com/nikhilm).

* For all you **PHP** buffs out there, Fredi Bach's
[sourceMakeup](http://jquery-jkit.com/sourcemakeup/) (we'll let the faux pas
with respect to our naming scheme slide), should do the trick nicely.

* **Lua** enthusiasts can get their fix with
[Robert Gieseke](https://github.com/rgieseke)'s [Locco](http://rgieseke.github.io/locco/).

* And if you happen to be a **.NET**
aficionado, check out [Don Wilson](https://github.com/dontangg)'s
[Nocco](http://dontangg.github.io/nocco/).

* Going further afield from the quick-and-dirty, [Groc](http://nevir.github.io/groc/)
is a **CoffeeScript** fork of Docco that adds a searchable table of contents,
and aims to gracefully handle large projects with complex hierarchies of code.

Note that not all ports will support all Docco features ... yet.


Main Documentation Generation Functions
---------------------------------------

Generate the documentation for our configured source file by copying over static
assets, reading all the source files in, splitting them up into prose+code
sections, highlighting each file in the appropriate language, and printing them
out in an HTML template.

    document = require './src/document'

Given a string of source code, **parse** out each block of prose and the code that
follows it — by detecting which is which, line by line — and then create an
individual **section** for it. Each section is an object with `docsText` and
`codeText` properties, and eventually `docsHtml` and `codeHtml` as well.

    parse = require './src/parse'

To **format** and highlight the now-parsed sections of code, we use **Highlight.js**
over stdio, and run the text of their corresponding comments through
**Markdown**, using [Marked](https://github.com/chjj/marked).

    format = require './src/format'

Configuration
-------------

**Configure** this particular run of Docco. We might use a passed-in external
template, or one of the built-in **layouts**. We only attempt to process
source files for languages for which we have definitions.

    configure = require './src/configure'

    getInformationOnFiles = require './src/getInformationOnFiles'

Helpers & Initial Setup
-----------------------

Require our external dependencies.

    _           = require 'underscore'
    fs          = require 'fs-extra'
    path        = require 'path'
    marked      = require 'marked'
    commander   = require 'commander'
    highlightjs = require 'highlight.js'
    path        = require 'path'
    glob        = require 'glob'

Languages are stored in JSON in the file `resources/languages.json`.
Each item maps the file extension to the name of the language and the
`symbol` that indicates a line comment. To add support for a new programming
language to Docco, just add it to the file.

    languages = JSON.parse fs.readFileSync(path.join(__dirname, 'resources', 'languages.json'))

Keep it DRY. Extract the docco **version** from `package.json`

    version = JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'))).version

Default configuration **options**. All of these may be extended by
user-specified options.

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

Command Line Interface
----------------------

Finally, let's define the interface to run Docco from the command line.
Parse options using [Commander](https://github.com/visionmedia/commander.js).

    run = (args = process.argv) ->
      config = defaults

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

      config = configure commander, defaults, languages

      setup = path.resolve config.setup
      if fs.existsSync(setup)
        config = _.extend(config, JSON.parse fs.readFileSync setup) if setup

      config.root = process.cwd()
      if config.sources.length isnt 0
        files =[]
        for globName in config.sources
          files = _.flatten _.union files, glob.sync path.resolve config.root, globName
        config.sources = []
        for file in files
          config.sources.push path.relative(config.root, file)

        config.informationOnFiles = getInformationOnFiles config

        document config
      else
        console.log commander.helpInformation()
      return

Public API
----------

    module.exports = Docco = {run, document, parse, format, languages, version}