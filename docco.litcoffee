**Docco** is a quick-and-dirty, hundred-line-long, literate-programming-style
documentation generator. It produces HTML
that displays your comments alongside your code. Comments are passed through
[Markdown](http://daringfireball.net/projects/markdown/syntax), and code is
passed through [Pygments](http://pygments.org/) syntax highlighting, if it
is present on the system.
This page is the result of running Docco against its own source file.

If you install Docco, you can run it from the command-line: `docco src/*.coffee`

...will generate an HTML documentation page for each of the named source files,
with a menu linking to the other pages, saving it into a `docs` folder.

The [source for Docco](http://github.com/jashkenas/docco) is available on GitHub,
and released under the MIT license.

To install Docco, first make sure you have [Node.js](http://nodejs.org/),
[Pygments](http://pygments.org/) (install the latest dev version of Pygments
from [its Mercurial repo](https://bitbucket.org/birkenfeld/pygments-main)), and
[CoffeeScript](http://coffeescript.org/).

Then, with NPM: `sudo npm install -g docco`

Docco can be used to process CoffeeScript, JavaScript, Ruby, Python, or TeX files.
Only single-line comments are processed -- block comments are ignored.


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


Main Documentation Generation Functions
---------------------------------------

Generate the documentation for a source file by reading it in, splitting it
up into comment/code sections, highlighting them for the appropriate language,
and merging them into an HTML template.

    generateDocumentation = (source, config, callback) ->
      fs.readFile source, (error, buffer) ->
        throw error if error
        code = buffer.toString()
        sections = parse source, code, config
        highlight source, sections, config, ->
          generateHtml source, sections, config
          callback()

    document = (sources, options = {}, callback = null) ->
      config = {}
      config[key] = defaults[key] for key,value of defaults
      config[key] = value for key,value of options if key of defaults

      config.sources = sources.filter((source) -> getLanguage source, config).sort()
      console.log "docco: skipped unknown type (#{m})" for m in sources when m not in config.sources

      config.doccoTemplate = _.template fs.readFileSync(config.template).toString()
      doccoStyles = fs.readFileSync(config.css).toString()

      ensureDirectory config.output, ->
        fs.writeFileSync path.join(config.output,path.basename(config.css)), doccoStyles
        files = config.sources.slice()
        nextFile = ->
          callback() if callback? and not files.length
          generateDocumentation files.shift(), config, nextFile if files.length
        nextFile()

Given a string of source code, parse out each comment and the code that
follows it, and create an individual **section** for it.

    parse = (source, code, config) ->
      lines    = code.split '\n'
      sections = []
      language = getLanguage source, config
      hasCode  = docsText = codeText = ''

      save = (docsText, codeText) ->
        sections.push {docsText, codeText}

      if language.literate
        for line, i in lines
          lines[i] = if blank line
            ''
          else if match = (/^([ ]{4}|\t)/).exec line
            line[match[0].length..]
          else
            '# ' + line

      for line in lines
        if (not line and prev is 'text') or (line.match(language.commentMatcher) and not line.match(language.commentFilter))
          if hasCode
            save docsText, codeText
            hasCode = docsText = codeText = ''
          docsText += line.replace(language.commentMatcher, '') + '\n'
          prev = 'text'
        else
          hasCode = yes
          codeText += line + '\n'
          prev = 'code'
      save docsText, codeText

      sections

Highlights parsed sections of code, using **Pygments** over stdio,
and runs the text of their corresponding comments through **Markdown**, using
[Marked](https://github.com/chjj/marked).  If Pygments is not present
on the system, output the code in plain text.

We process all sections with single calls to Pygments and Marked, by
inserting marker comments between them, and then splitting the result
string wherever the marker occurs.

    highlight = (source, sections, config, callback) ->
      language = getLanguage source, config
      pygments = spawn 'pygmentize', [
        '-l', language.name,
        '-f', 'html',
        '-O', 'encoding=utf-8,tabsize=2'
      ]
      output = ''
      code = (section.codeText for section in sections).join language.codeSplitText
      docs = (section.docsText for section in sections).join language.docsSplitText

      pygments.stderr.on 'data', ->
      pygments.stdin.on 'error', ->
      pygments.stdout.on 'data', (result) ->
        output += result if result

      pygments.on 'exit', ->
        output = output.replace(highlightStart, '').replace(highlightEnd, '')
        if output is ''
          codeFragments = (htmlEscape section.codeText for section in sections)
        else
          codeFragments = output.split language.codeSplitHtml
        docsFragments = marked(docs).split language.docsSplitHtml

        for section, i in sections
          section.codeHtml = highlightStart + codeFragments[i] + highlightEnd
          section.docsHtml = docsFragments[i]
        callback()

      if pygments.stdin.writable
        pygments.stdin.write code
        pygments.stdin.end()

Escape an html string, to produce valid non-highlighted output when pygments
is not present on the system.

    htmlEscape = (string) ->
      string.replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;')
        .replace(/\//g,'&#x2F;')

Once all of the code is finished highlighting, we can generate the HTML file by
passing the completed sections into the template, and then writing the file to
the specified output path.

    generateHtml = (source, sections, config) ->
      destination = (filepath) ->
        path.join(config.output, path.basename(filepath, config.fullExtension) + '.html')
      title = path.basename source
      dest  = destination source
      html  = config.doccoTemplate {
        title      : title,
        sections   : sections,
        sources    : config.sources,
        path       : path,
        destination: destination
        css        : path.basename(config.css)
      }
      console.log "docco: #{source} -> #{dest}"
      fs.writeFileSync dest, html


Helpers & Setup
---------------

Require our external dependencies.

    _             = require 'underscore'
    fs            = require 'fs'
    path          = require 'path'
    marked        = require 'marked'
    commander     = require 'commander'
    {spawn, exec} = require 'child_process'

Read resource file and return its content.

    getResource = (name) ->
      fullPath = path.join __dirname, 'resources', name
      fs.readFileSync(fullPath).toString()

Regex to match a blank line.

    blank = (line) ->
      /^\s*$/.test line

Languages are stored in JSON format in the file `resources/languages.json`
Each item maps the file extension to the name of the Pygments lexer and the
symbol that indicates a comment. To add a new language, modify the file.

    languages = JSON.parse getResource 'languages.json'

Build out the appropriate matchers and delimiters for each language.

    for ext, l of languages

      # Does the line begin with a comment?
      l.commentMatcher = ///^\s*#{l.symbol}\s?///

      # Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_(Unix\))
      # and interpolations...
      l.commentFilter = /(^#![/]|^\s*#\{)/

      # The dividing token we feed into Pygments, to delimit the boundaries between
      # sections.
      l.codeSplitText = "\n#{l.symbol}DIVIDER\n"

      # The mirror of `codeSplitText` that we expect Pygments to return. We can split
      # on this to recover the original sections.
      # Note: the class is "c" for Python and "c1" for the other languages
      l.codeSplitHtml = ///\n*<span\sclass="c1?">#{l.symbol}DIVIDER<\/span>\n*///

      # The dividing token we feed into markdown, to delimit the boundaries between
      # sections.
      l.docsSplitText = "\n##{l.name}DOCDIVIDER\n"

      # The mirror of `docsSplitText` that we expect markdown to return. We can split
      # on this to recover the original sections.
      l.docsSplitHtml = ///<h1>#{l.name}DOCDIVIDER</h1>///

Get the current language we're documenting, based on the extension.

    getLanguage = (source, config) ->
      ext  = config.fullExtension = config.extension or path.extname(source)
      lang = languages[ext]
      if lang.name is 'markdown'
        codeExt = path.extname(path.basename(source, ext))
        if codeExt and codeLang = languages[codeExt]
          config.fullExtension = codeExt + ext
          lang = _.extend {}, codeLang, {literate: yes}
      lang

Ensure that the destination directory exists.

    ensureDirectory = (dir, cb, made=null) ->
      mode = parseInt '0777', 8
      fs.mkdir dir, mode, (er) ->
        return cb null, made || dir if not er
        if er.code == 'ENOENT'
          return ensureDirectory path.dirname(dir), (er, made) ->
            if er then cb er, made else ensureDirectory dir, cb, made
        cb er, made

The start of each Pygments highlight block.

    highlightStart = '<div class="highlight"><pre>'

The end of each Pygments highlight block.

    highlightEnd   = '</pre></div>'

Extract the docco version from `package.json`

    version = JSON.parse(fs.readFileSync("#{__dirname}/package.json")).version

Default configuration options.

    defaults =
      template : "#{__dirname}/resources/docco.jst"
      css      : "#{__dirname}/resources/docco.css"
      output   : "docs/"
      extension: null


Run from Commandline
--------------------

Run Docco from a set of command line arguments.
Parse command line using [Commander JS](https://github.com/visionmedia/commander.js).

    run = (args=process.argv) ->
      commander.version(version)
        .usage("[options] <filePattern ...>")
        .option("-c, --css [file]","use a custom css file",defaults.css)
        .option("-o, --output [path]","use a custom output path",defaults.output)
        .option("-t, --template [file]","use a custom .jst template",defaults.template)
        .option("-e, --extension <ext>","use the given file extension for all inputs",defaults.extension)
        .parse(args)
        .name = "docco"
      if commander.args.length
        document(commander.args.slice(),commander)
      else
        console.log commander.helpInformation()


Public API
----------

    Docco = module.exports = {run, document, parse, version}
