    _ = require 'underscore'
    fs = require 'fs-extra'
    path = require 'path'
    getLanguage = require './getLanguage'
    buildMatchers = require './buildMatchers'

**Configure** this particular run of Docco. We might use a passed-in external
template, or one of the built-in **layouts**. We only attempt to process
source files for languages for which we have definitions.

    module.exports = configure = (options, defaults, languages) ->
      config = _.extend {}, defaults, _.pick(options, _.keys(defaults)...)

Build out the appropriate matchers and delimiters for each language.

      config.languages = buildMatchers languages

The user is able to override the layout file used with the `--template` parameter.
In this case, it is also neccessary to explicitly specify a stylesheet file.
These custom templates are compiled exactly like the predefined ones, but the `public` folder
is only copied for the latter.

      if options.template
        unless options.css
          console.warn "docco: no stylesheet file specified"
        config.layout = null
      else
        dir = config.layout = path.join __dirname, '../resources', config.layout
        config.public       = path.join dir, 'public' if fs.existsSync path.join dir, 'public'
        config.template     = path.join dir, 'docco.jst'
        config.css          = options.css or path.join dir, 'docco.css'
      config.template = _.template fs.readFileSync(config.template).toString()

      if options.marked
        config.marked = JSON.parse fs.readFileSync(options.marked)

      config.sources = options.args.filter((source) ->
        lang = getLanguage source, languages, config.extension
        console.warn "docco: skipped unknown type (#{path.basename source})" unless lang
        lang
      ).sort()

      config
