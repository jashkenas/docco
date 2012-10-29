Docco         = require './src/docco'
CoffeeScript  = require 'coffee-script'
{spawn, exec} = require 'child_process'
fs            = require 'fs'
path          = require 'path'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'
option '-w', '--watch', 'continually build the docco library'

task 'build', 'build the docco library', (options) ->
  coffee = spawn 'node', ['./node_modules/coffee-script/bin/coffee','-c' + (if options.watch then 'w' else ''), '-o', 'lib', 'src']
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
  runTests Docco
    
# Simple test runner, borrowed from [CoffeeScript](http://coffeescript.org/).
runTests = (Docco) ->
  startTime   = Date.now()
  currentFile = null
  currentTest = null
  currentSource = null
  passedTests = 0
  passedEqual = 0
  failedEqual = 0
  failures    = []

  global[name] = func for name, func of require 'assert'

  # Convenience alias.
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
      
  # See http://wiki.ecmascript.org/doku.php?id=harmony:egal
  egal = (a, b) ->
    if a is b
      result = a isnt 0 or 1/a is 1/b
    else
      result = a isnt a and b isnt b
    if result then ++passedEqual else ++failedEqual
    result

  # A recursive functional equivalence helper; uses egal for testing equivalence.
  arrayEgal = (a, b) ->
    if egal a, b
      ++passedEqual
      yes
    else if a instanceof Array and b instanceof Array
      if a.length isnt b.length
        ++failedEqual
        return no
      for el, idx in a when not arrayEgal el, b[idx]
        ++failedEqual
        return no
      ++passedEqual
      yes

  global.eq      = (a, b, msg) -> 
    try
      return ok egal(a, b), msg
    catch e
      e.description = msg if msg?
      e.source      = currentSource
      e.testName    = currentTest
      failures.push filename: currentFile, error: e 
    false
  global.arrayEq = (a, b, msg) -> ok arrayEgal(a,b), msg

  # When all the tests have run, collect and print errors.
  # If a stacktrace is available, output the compiled function source.
  process.on 'exit', ->
    time = ((Date.now() - startTime) / 1000).toFixed(2)
    for fail in failures
      {error, filename}  = fail
      jsFilename         = filename.replace(/\.coffee$/,'.js')
      match              = error.stack?.match(new RegExp(fail.file+":(\\d+):(\\d+)"))
      match              = error.stack?.match(/on line (\d+):/) unless match
      [match, line, col] = match if match
      console.log ''
      console.log "  #{error.testName}" if error.testName
      console.log "  #{error.description}"
      console.log "  #{error.stack}"
      console.log "  #{jsFilename}: line #{line ? 'unknown'}, column #{col ? 'unknown'}"
      console.log "  #{error.source}" if error.source
    console.log [
      ""
      "Testing completed in #{time} seconds"
      "  #{passedTests} tests passed, #{failures.length} failed"
      "  #{passedEqual} asserts passed, #{failedEqual} failed"
      ""
    ].join '\n'
    return if failures.length > 0 then 1 else 0

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
