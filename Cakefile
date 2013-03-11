Docco         = require './src/docco'
CoffeeScript  = require 'coffee-script'
{spawn, exec} = require 'child_process'
fs            = require 'fs'
path          = require 'path'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'
option '-w', '--watch', 'continually build the docco library'

task 'build', 'build the docco library', (options) ->
  coffee = spawn 'coffee', ['-c' + (if options.watch then 'w' else ''), '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'install', 'install the `docco` command into /usr/local (or --prefix)', (options) ->
  base = options.prefix or '/usr/local'
  lib  = base + '/lib/docco'
  exec([
    'mkdir -p ' + lib
    'cp -rf bin README resources vendor lib ' + lib
    'ln -sf ' + lib + '/bin/docco ' + base + '/bin/docco'
  ].join(' && '), (err, stdout, stderr) ->
   if err then console.error stderr
  )

task 'doc', 'rebuild the Docco documentation', ->
  exec([
    'bin/docco src/docco.coffee'
    'sed "s/docco.css/resources\\/docco.css/" < docs/docco.html > index.html'
    'rm -r docs'
  ].join(' && '), (err) ->
    throw err if err
  )

task 'test', 'run the Docco test suite', ->
  runTests()

# Simple test runner, adapted from [CoffeeScript](http://coffeescript.org/).
runTests = () ->
  startTime     = Date.now()
  currentFile   = null
  currentTest   = null
  currentSource = null
  passedTests   = 0
  passedAssert  = 0
  failedAssert  = 0
  failures      = []
  done          = false

  # Wrap each assert function in a try/catch block to report passed/failed assertions.
  wrapAssert = (func,name) ->
    return () ->
      try
        result = func.apply this, arguments
        ++passedAssert
      catch e
        ++failedAssert
        e.description = arguments[2] if arguments.length == 3
        e.source      = currentSource
        e.testName    = currentTest
        failures.push
          filename: currentFile
          error: e
      result

  global[name] = wrapAssert(func,name) for name, func of require 'assert'
  global.Docco = Docco

  # Our test helper function for delimiting different test cases.
  global.test = (description, fn) ->
    try
      fn.test = {description, currentFile}
      currentTest = description
      currentSource = fn.toString() if fn.toString?
      fn.call(fn)
      ++passedTests
    catch e
      e.testName    = currentTest
      e.description = description if description?
      e.source      = fn.toString() if fn.toString?
      failures.push filename: currentFile, error: e

  # When all the tests have run, collect and print errors.
  # If a stacktrace is available, output the compiled function source.
  process.on 'exit', ->
    return if done
    done = true
    time = ((Date.now() - startTime) / 1000).toFixed(2)
    for fail in failures
      {error, filename}  = fail
      jsFilename         = filename.replace(/\.coffee$/,'.js')
      match              = error.stack?.match(new RegExp(fail.filename+":(\\d+):(\\d+)"))
      match              = error.stack?.match(/on line (\d+):/) unless match
      [match, line, col] = match if match
      console.log "\n--------------------------------------------------------"
      console.log "  FAILED: #{error.testName}\n" if error.testName
      console.log "  FILE  :#{jsFilename}: line #{line ? 'unknown'}, column #{col ? 'unknown'}"
      console.log "  ERROR : #{error.description}" if error.description
      console.log "  STACK : #{error.stack}" if error.stack
      console.log "  SOURCE: #{error.source}" if error.source
    console.log "--------------------------------------------------------"
    console.log "Testing completed in #{time} seconds"
    console.log "  #{passedTests} tests passed, #{failures.length} failed"
    console.log "  #{passedAssert} asserts passed, #{failedAssert} failed"
    console.log "--------------------------------------------------------"
    process.exit if failures.length > 0 then 1 else 0

  # Run every test in the `test` folder, recording failures.
  files = fs.readdirSync 'test'
  for file in files when file.match /\.coffee$/i
    currentFile = filename = path.join 'test', file
    code = fs.readFileSync filename
    try
      CoffeeScript.run code.toString(), {filename}
    catch error
      error.description = currentTest
      failures.push {filename, error}
  return !failures.length
