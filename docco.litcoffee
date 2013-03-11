Docco
=====

**Docco** is a quick-and-dirty documentation generator, written in
[Literate CoffeeScript](http://coffeescript.org/#literate).
It produces an HTML document that displays your comments intermingled with your
code. All prose is passed through
[Markdown](http://daringfireball.net/projects/markdown/syntax), and code is
passed through [Pygments](http://pygments.org/) syntax highlighting (if you
happen to have it installed). This page is the result of running Docco against
its own
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

* If **Node.js** doesn't run on your platform, or you'd prefer a more
convenient package, get [Ryan Tomayko](http://github.com/rtomayko)'s
[Rocco](http://rtomayko.github.com/rocco/rocco.html), the Ruby port that's
available as a gem.

* If you're writing shell scripts, try
[Shocco](http://rtomayko.github.com/shocco/), a port for the **POSIX shell**,
also by Mr. Tomayko.

* If Python's more your speed, take a look at
[Nick Fitzgerald](http://github.com/fitzgen)'s [Pycco](http://fitzgen.github.com/pycco/).

* For **Clojure** fans, [Fogus](http://blog.fogus.me/)'s
[Marginalia](http://fogus.me/fun/marginalia/) is a bit of a departure from
"quick-and-dirty", but it'll get the job done.

* **Lua** enthusiasts can get their fix with
[Robert Gieseke](https://github.com/rgieseke)'s [Locco](http://rgieseke.github.com/locco/).

* And if you happen to be a **.NET**
aficionado, check out [Don Wilson](https://github.com/dontangg)'s
[Nocco](http://dontangg.github.com/nocco/).

Note that not all ports will support all Docco features ... yet.


Main Documentation Generation Functions
---------------------------------------

Generate the documentation for our configured source file by copying over static
assets, reading all the source files in, splitting them up into prose+code
sections, highlighting each file in the appropriate language, and printing them
out in an HTML template.

    document = (config) ->
      exec "mkdir -p #{config.output}", ->

        exec "cp -f #{config.css} #{config.output}"
        exec "cp -fR #{config.public} #{config.output}" if fs.existsSync config.public
        files = config.sources.slice()

        nextFile = ->
          source = files.shift()
          fs.readFile source, (error, buffer) ->
            throw error if error

            code = buffer.toString()
            sections = parse source, code, config
            highlight source, sections, config, ->
              writeHtml source, sections, config
              nextFile() if files.length

        nextFile()

Given a string of source code, **parse** out each block of prose and the code that
follows it — by detecting which is which, line by line — and then create an
individual **section** for it. Each section is an object with `docsText` and
`codeText` properties, and eventually `docsHtml` and `codeHtml` as well.

    parse = (source, code, config) ->
      lines    = code.split '\n'
      sections = []
      lang     = getLanguage source, config
      hasCode  = docsText = codeText = ''

      save = ->
        sections.push {docsText, codeText}
        hasCode = docsText = codeText = ''

Our quick-and-dirty implementation of the literate programming style. Simply
invert the prose and code relationship on a per-line basis, and then continue as
normal below.

      if lang.literate
        for line, i in lines
          lines[i] = if /^\s*$/.test line
            ''
          else if match = (/^([ ]{4}|\t)/).exec line
            line[match[0].length..]
          else
            lang.symbol + ' ' + line

      for line in lines
        if (not line and prev is 'text') or
            (line.match(lang.commentMatcher) and not line.match(lang.commentFilter))
          save() if hasCode
          docsText += (line = line.replace(lang.commentMatcher, '')) + '\n'
          save() if /^(---+|===+)$/.test line
          prev = 'text'
        else
          hasCode = yes
          codeText += line + '\n'
          prev = 'code'
      save()

      sections

To **highlight** and format the now-parsed sections of code, we use **Pygments**
over stdio, and run the text of their corresponding comments through
**Markdown**, using [Marked](https://github.com/chjj/marked). If Pygments is
not present on the system, simply output the code without colors.

We are able to process *all* of the sections with a single call to Pygments and
a single call to Marked, by inserting marker comments between sections,
concatenating, and then splitting the result string wherever the marker occurs.

    highlight = (source, sections, config, callback) ->

      lang = getLanguage source, config
      pygments = spawn 'pygmentize', [
        '-l', lang.name,
        '-f', 'html',
        '-O', 'encoding=utf-8,tabsize=2'
      ]
      output = ''
      code = (section.codeText for section in sections).join lang.codeSplitText
      docs = (section.docsText for section in sections).join lang.docsSplitText

      pygments.stdout.on 'data', (result) ->
        output += result if result

      pygments.on 'exit', ->
        output = output.replace(highlightStart, '').replace(highlightEnd, '')
        codeFragments = if output
          output.split lang.codeSplitHtml
        else
          (_.escape section.codeText for section in sections)
        docsFragments = marked(docs).split lang.docsSplitHtml

        for section, i in sections
          section.codeHtml = highlightStart + codeFragments[i] + highlightEnd
          section.docsHtml = docsFragments[i]
        callback()

      if pygments.stdin.writable
        pygments.stdin.write code
        pygments.stdin.end()

Once all of the code has finished highlighting, we can **write** the resulting
documentation file by passing the completed HTML sections into the template,
and rendering it to the specified output path.

    writeHtml = (source, sections, config) ->

      destination = (file) ->
        path.join(config.output, path.basename(file, path.extname(file)) + '.html')

The **title** of the file is either the first heading in the prose, or the
name of the source file.

      firstBlock = marked.lexer(sections[0].docsText)[0]
      hasTitle = firstBlock?.type is 'heading'
      title = if hasTitle then firstBlock.text else path.basename source

      html = config.template {sources: config.sources, css: path.basename(config.css),
        title, hasTitle, sections, path, destination,}

      console.log "docco: #{source} -> #{destination source}"
      fs.writeFileSync destination(source), html


Configuration
-------------

Default configuration **options**. All of these may be overriden by command-line
options.

    defaults =
      layout:     'parallel'
      output:     'docs/'
      template:   null
      css:        null
      extension:  null

**Configure** this particular run of Docco. We might use a passed-in external
template, or one of the built-in **layouts**. We only attempt to process
source files for languages for which we have definitions.

    configure = (options) ->
      config = _.extend {}, defaults, _.pick(options, _.keys(defaults)...)

      if options.template or options.css
        config.layout = null
      else
        dir = config.layout = "#{__dirname}/resources/#{config.layout}"
        config.public       = "#{dir}/public" if fs.existsSync "#{dir}/public"
        config.template     = "#{dir}/docco.jst"
        config.css          = "#{dir}/docco.css"
      config.template = _.template fs.readFileSync(config.template).toString()

      config.sources = options.args.filter((source) ->
        lang = getLanguage source, config
        console.warn "docco: skipped unknown type (#{m})" unless lang
        lang
      ).sort()

      config


Helpers & Initial Setup
-----------------------

Require our external dependencies.

    _             = require 'underscore'
    fs            = require 'fs'
    path          = require 'path'
    marked        = require 'marked'
    commander     = require 'commander'
    {spawn, exec} = require 'child_process'

Languages are stored in JSON in the file `resources/languages.json`.
Each item maps the file extension to the name of the Pygments lexer and the
`symbol` that indicates a line comment. To add support for a new programming
language to Docco, just add it to the file.

    languages = JSON.parse fs.readFileSync("#{__dirname}/resources/languages.json")

Build out the appropriate matchers and delimiters for each language.

    for ext, l of languages

Does the line begin with a comment?

      l.commentMatcher = ///^\s*#{l.symbol}\s?///

Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_(Unix\)) and interpolations...

      l.commentFilter = /(^#![/]|^\s*#\{)/

The dividing token we feed into Pygments, to delimit the boundaries between
sections.

      l.codeSplitText = "\n#{l.symbol}DIVIDER\n"

The mirror of `codeSplitText` that we expect Pygments to return. We can split
on this to recover the original sections.
*Note: the class is "c" for Python and "c1" for the other languages.*

      l.codeSplitHtml = ///\n*<span\sclass="c1?">#{l.symbol}DIVIDER<\/span>\n*///

The dividing token we feed into Markdown, to delimit the boundaries between
sections.

      l.docsSplitText = "\n##{l.name}DOCDIVIDER\n"

The mirror of `docsSplitText` that we expect markdown to return. We can split
on this to recover the original sections.

      l.docsSplitHtml = ///<h1>#{l.name}DOCDIVIDER</h1>///

A function to get the current language we're documenting, based on the
file extension. Detect and tag "literate" `.ext.md` variants.

    getLanguage = (source, config) ->
      ext  = config.extension or path.extname(source)
      lang = languages[ext]
      if lang and lang.name is 'markdown'
        codeExt = path.extname(path.basename(source, ext))
        if codeExt and codeLang = languages[codeExt]
          lang = _.extend {}, codeLang, {literate: yes}
      lang

The start of each Pygments highlight block.

    highlightStart = '<div class="highlight"><pre>'

The end of each Pygments highlight block.

    highlightEnd   = '</pre></div>'

Keep it DRY. Extract the docco **version** from `package.json`

    version = JSON.parse(fs.readFileSync("#{__dirname}/package.json")).version


Command Line Interface
----------------------

Finally, let's define the interface to run Docco from the command line.
Parse options using [Commander](https://github.com/visionmedia/commander.js).

    run = (args = process.argv) ->
      d = defaults
      commander.version(version)
        .usage('[options] files')
        .option('-l, --layout [name]',    'choose a built-in layout (parallel or linear)', d.parallel)
        .option('-o, --output [path]',    'output to a given folder', d.output)
        .option('-c, --css [file]',       'use a custom css file', d.css)
        .option('-t, --template [file]',  'use a custom .jst template', d.template)
        .option('-e, --extension [ext]',  'assume a file extension for all inputs', d.extension)
        .parse(args)
        .name = "docco"
      if commander.args.length
        document configure commander
      else
        console.log commander.helpInformation()


Public API
----------

    Docco = module.exports = {run, document, parse, version}

That's all, folks!
