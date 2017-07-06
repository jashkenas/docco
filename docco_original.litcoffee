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

    document = (config = {}, callback) ->

      fs.mkdirs config.output, ->

        callback or= (error) -> throw error if error
        copyAsset  = (file, callback) ->
          return callback() unless fs.existsSync file
          fs.copy file, path.join(config.output, path.basename(file)), callback

        complete   = ->
          copyAsset config.css, (error) ->
            return callback error if error
            return copyAsset config.public, callback if fs.existsSync config.public
            callback()

        files = config.sources.slice()

        nextFile = () ->
          source = files.shift()

If keeping the directory hierarchy, then insert the file's relative directory in to the path.

          lang = getLanguage source, config

          if config.flatten and !lang.copy
            toDirectory = config.output
          else
            toDirectory = config.root + '/' + config.output + '/' + (path.dirname source)

Make sure the target directory exits.

          # todo: async versions of exits and mkdir.
          if !fs.existsSync(toDirectory)
            fs.mkdirsSync(toDirectory)

Implementation of copying files if specified in the language file

          if lang.copy
            toFile = toDirectory + '/' + path.basename source
            console.log "docco: #{source} -> #{toFile}"

            fs.copy source, toFile, (error, result) ->
              return callback(error) if error
              if files.length then nextFile() else complete()

Implementation of spliting comments and code into split view html files.

          else
            fs.readFile source, (error, buffer) ->
              return callback(error) if error

              code = buffer.toString()
              sections = parse source, code, config
              format source, sections, config
              toFile = toDirectory + '/' + (path.basename source, path.extname source)

              write source, sections, config

              if files.length then nextFile() else complete()

        nextFile()

Given a string of source code, **parse** out each block of prose and the code that
follows it — by detecting which is which, line by line — and then create an
individual **section** for it. Each section is an object with `docsText` and
`codeText` properties, and eventually `docsHtml` and `codeHtml` as well.

    parse = (source, code, config = {}) ->
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
        isText = maybeCode = yes
        for line, i in lines
          lines[i] = if maybeCode and match = /^([ ]{4}|[ ]{0,3}\t)/.exec line
            isText = no
            line[match[0].length..]
          else if maybeCode = /^\s*$/.test line
            if isText then lang.symbol else ''
          else
            isText = yes
            lang.symbol + ' ' + line

      for line in lines
        if lang.linkMatcher and line.match(lang.linkMatcher)
          LINK_REGEX = /\((.+)\)/
          TEXT_REGEX = /\[(.+)\]/
          links = LINK_REGEX.exec(line)
          texts = TEXT_REGEX.exec(line)
          if links? and links.length > 1 and texts? and texts.length > 1
            link = links[1]
            text = texts[1]
            codeText += '<div><img src="'+link+'"></img><p>'+text+'</p></div>' + '\n'
          hasCode = yes
        else if lang.sectionMatcher and line.match(lang.sectionMatcher)
          save() if hasCode
          docsText += (line = line.replace(lang.commentMatcher, '')) + '\n'
          save() # if /^(---+|===+)$/.test line
        else if line.match(lang.commentMatcher) and not line.match(lang.commentFilter)
          save() if hasCode
          docsText += (line = line.replace(lang.commentMatcher, '')) + '\n'
          save() if /^(---+|===+)$/.test line
        else
          hasCode = yes
          codeText += line + '\n'
      save()

      sections

To **format** and highlight the now-parsed sections of code, we use **Highlight.js**
over stdio, and run the text of their corresponding comments through
**Markdown**, using [Marked](https://github.com/chjj/marked).

    format = (source, sections, config) ->
      language = getLanguage source, config

Pass any user defined options to Marked if specified via command line option

      markedOptions =
        smartypants: true

      if config.marked
        markedOptions = config.marked

      marked.setOptions markedOptions

Tell Marked how to highlight code blocks within comments, treating that code
as either the language specified in the code block or the language of the file
if not specified.

      marked.setOptions {
        highlight: (code, lang) ->
          lang or= language.name

          if highlightjs.getLanguage(lang)
            highlightjs.highlight(lang, code).value
          else
            console.warn "docco: couldn't highlight code block with unknown language '#{lang}' in #{source}"
            code
      }

      for section, i in sections
        if language.html
          section.codeHtml = section.codeText
        else
          code = highlightjs.highlight(language.name, section.codeText).value
          code = code.replace(/\s+$/, '')
          section.codeHtml = "<div class='highlight'><pre>#{code}</pre></div>"
        section.docsHtml = marked(section.docsText)

Once all of the code has finished highlighting, we can **write** the resulting
documentation file by passing the completed HTML sections into the template,
and rendering it to the specified output path.

    write = (source, sections, config) ->

      console.log("source: "+source)

      # todo: figure out how to remove the breaking change here. normally this should return file+'.html'

      destination = (file) ->
        file

      objectValues = (obj) ->
        Object.keys(obj).map((key) ->
          obj[key]
        )

      firstSection = _.find sections, (section) ->
        section.docsText.length > 0
      first = marked.lexer(firstSection.docsText)[0] if firstSection
      hasTitle = first and first.type is 'heading' and first.depth is 1
      title = if hasTitle then first.text else path.basename source

      fileInfo = config.informationOnFiles[source]
      others = objectValues(fileInfo.others)
      html = config.template { sources: others, css: fileInfo.destination.css,
        title, hasTitle, sections, path, destination }

      console.log "docco: #{source} -> #{destination fileInfo.destination.path}"
      fs.writeFileSync destination(fileInfo.destination.path), html
      return


Configuration
-------------

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

**Configure** this particular run of Docco. We might use a passed-in external
template, or one of the built-in **layouts**. We only attempt to process
source files for languages for which we have definitions.

    configure = (options) ->
      config = _.extend {}, defaults, _.pick(options, _.keys(defaults)...)

      config.languages = buildMatchers config.languages

The user is able to override the layout file used with the `--template` parameter.
In this case, it is also neccessary to explicitly specify a stylesheet file.
These custom templates are compiled exactly like the predefined ones, but the `public` folder
is only copied for the latter.

      if options.template
        unless options.css
          console.warn "docco: no stylesheet file specified"
        config.layout = null
      else
        dir = config.layout = path.join __dirname, 'resources', config.layout
        config.public       = path.join dir, 'public' if fs.existsSync path.join dir, 'public'
        config.template     = path.join dir, 'docco.jst'
        config.css          = options.css or path.join dir, 'docco.css'
      config.template = _.template fs.readFileSync(config.template).toString()
      console.log("Template:"+config.template)

      if options.marked
        config.marked = JSON.parse fs.readFileSync(options.marked)

      config.sources = options.args.filter((source) ->
        lang = getLanguage source, config
        console.warn "docco: skipped unknown type (#{path.basename source})" unless lang
        lang
      ).sort()

      config

    getSourceInformation = (file, rootDirectory, flatten) ->
      source = path.parse file
      source.root = rootDirectory
      source.file = file
      source.path = source.root+'/'+source.file
      if flatten
        source.relativefile = source.base
      else
        source.relativefile = source.file
      source

    getDestinationInformation = (language, source, rootDirectory, targetDirectory, flatten) ->
      destination = { }
      destination.root = rootDirectory

      if flatten and !language.copy
        destination.dir = targetDirectory
      else
        destination.dir = if source.dir is '' then targetDirectory else targetDirectory+"/"+source.dir

      if language.copy
        destination.ext = source.ext
      else
        destination.ext = '.html'

      destination.base = source.name + destination.ext
      destination.name = source.name
      destination.file = destination.dir+'/'+source.name + destination.ext
      if flatten and !language.copy
        destination.relativefile = source.name+destination.ext
      else
        destination.relativefile = if source.dir is '' then source.name+destination.ext else source.dir+'/'+source.name + destination.ext

      destination.path = destination.root+'/'+destination.file
      destination.pathdir = path.dirname destination.path

      destination

    getRelativePath = (fromFile, toFile, base) ->
      console.log("From: #{fromFile} To: #{toFile}")
      fromTo = path.relative(fromFile,toFile)
      if fromTo is '' or fromTo is '.' or fromTo is '..' or fromTo is '../'
        fromTo = base
      else
        fromTo = fromTo.slice(3)

      console.log("Path: #{fromTo}")
      fromTo

    getCSSPath = (cssFile, targetDirectory, file) ->
      css = path.parse(cssFile)
      css.file = targetDirectory+'/'+css.base

      cssPath = path.relative(file, css.file)
      cssPath = cssPath.slice(3)

      cssPath

    getOthers = (file, informationOnFiles, config) ->
      sourceFileInformation = informationOnFiles[file]
      source = sourceFileInformation.source
      others = {}
      for other in config.sources
        destinationFileInformation = informationOnFiles[other]
        target = destinationFileInformation.destination

        console.log(JSON.stringify(destinationFileInformation.destination,null,2))
        others[target.base] = getRelativePath source.relativefile, target.relativefile, target.base

      others

    getInformationOnFiles = (config) ->
      targetDirectory = config.output
      sourceDirectory = config.root
      rootDirectory = config.root

For each source file, figure out it's relative path to the source directory,
the filename without and extension, and the extension.  Then figure out the 
relative path to the targetDirectory. Then figure out the relative path between
the two.

      informationOnFiles = {}
      for file in config.sources
        destinations = {}

First the source name:

        source = getSourceInformation(file, rootDirectory, config.flatten)

Next the destination:

        language = getLanguage file, config

        destination = getDestinationInformation(language, source, rootDirectory, targetDirectory, config.flatten)

Now, figure out the relative paths the css:

        destination.css = getCSSPath(config.css, targetDirectory, destination.file)

        informationOnFiles[file] = {}
        informationOnFiles[file].destination = destination
        informationOnFiles[file].source = source

Now, figure out the relative paths to the other source files:

      for file in config.sources
        informationOnFiles[file].others = getOthers(file, informationOnFiles, config)

      return informationOnFiles


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

Build out the appropriate matchers and delimiters for each language.

    buildMatchers = (languages) ->
      for ext, l of languages

Does the line begin with a comment?

        l.commentMatcher = ///^\s*#{l.symbol}\s?///

Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_%28Unix%29) and interpolations...

        l.commentFilter = /(^#![/]|^\s*#\{)/

Look for links if necessary.

        if l.link
          l.linkMatcher = ///^#{l.link}\[(.+)\]\((.+)\)///

Look for explict section breaks

        if l.section
          l.sectionMatcher = ///^#{l.section}\s?///

      languages
      
    languages = buildMatchers languages

A function to get the current language we're documenting, based on the
file extension. Detect and tag "literate" `.ext.md` variants.

    getLanguage = (source, config) ->
      ext  = config.extension or path.extname(source) or path.basename(source)
      lang = config.languages?[ext] or languages[ext]
      if lang and lang.name is 'markdown'
        codeExt = path.extname(path.basename(source, ext))
        if codeExt and codeLang = languages[codeExt]
          lang = _.extend {}, codeLang, {literate: yes}
      lang

Keep it DRY. Extract the docco **version** from `package.json`

    version = JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'))).version

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

      config = configure commander

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

    Docco = module.exports = {
      run,
      document,
      parse,
      format,
      write,
      version,
      languages,
      getDestinationInformation,
      getLanguage,
      getInformationOnFiles,
      getCSSPath,
      getRelativePath,
      getOthers
    }
