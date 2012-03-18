Docco         = require './lib/docco'
CoffeeScript  = require 'coffee-script'
{spawn, exec} = require 'child_process'
fs            = require 'fs'
path          = require 'path'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'
option '-w', '--watch', 'continually build the docco library'

task 'build', 'build the docco library', (options) ->
  coffee = spawn 'coffee', ['-c' + (if options.watch then 'w' else ''), '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

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

task 'weigh', 'display docco.coffee line count distribution', ->
  # Parse out code/doc sections for `docco.cofeee`
  file_path     = path.join __dirname, 'src/docco.coffee'
  file_contents = fs.readFileSync(file_path, 'utf-8').toString()
  file_lines    = file_contents.split '\n'
  sections      = Docco.parse file_path, file_contents, true
  
  # Iterate over the sections and determine lines of code, 
  # documentation, and whitespace.
  docs_count = code_count = 0
  for section in sections
    code_count += 1 for l in section.code_text.split('\n') when l.trim() != ''
    docs_count += 1 for l in section.docs_text.split('\n') when l.trim() != ''
  blank_count = file_lines.length - docs_count - code_count
  total_count = docs_count+code_count+blank_count
  if total_count != file_lines.length
    throw "Total line count mismatch between file and computed values" 

  # Print summary information.
  console.log [
    "docco.coffee line counts:"
    "------------------------"
    " Documentation : #{docs_count}"
    " Code          : #{code_count}"
    " Whitespace    : #{blank_count}"
    "------------------------"
    " Total         : #{total_count}"
  ].join('\n')

task 'test', 'run the Docco test suite', ->
  runTests Docco
    
# Simple test runner, borrowed from [CoffeeScript](http://coffeescript.org/).
runTests = (Docco) ->
  startTime   = Date.now()
  currentFile = null
  passedTests = 0
  failures    = []

  global[name] = func for name, func of require 'assert'

  # Convenience alias.
  global.Docco = Docco

  # Our test helper function for delimiting different test cases.
  global.test = (description, fn) ->
    try
      fn.test = {description, currentFile}
      fn.call(fn)
      ++passedTests
    catch e
      e.description = description if description?
      e.source      = fn.toString() if fn.toString?
      failures.push filename: currentFile, error: e 
      
  # See http://wiki.ecmascript.org/doku.php?id=harmony:egal
  egal = (a, b) ->
    if a is b
      a isnt 0 or 1/a is 1/b
    else
      a isnt a and b isnt b

  # A recursive functional equivalence helper; uses egal for testing equivalence.
  arrayEgal = (a, b) ->
    if egal a, b then yes
    else if a instanceof Array and b instanceof Array
      return no unless a.length is b.length
      return no for el, idx in a when not arrayEgal el, b[idx]
      yes

  global.eq      = (a, b, msg) -> ok egal(a, b), msg
  global.arrayEq = (a, b, msg) -> ok arrayEgal(a,b), msg

  # When all the tests have run, collect and print errors.
  # If a stacktrace is available, output the compiled function source.
  process.on 'exit', ->
    time = ((Date.now() - startTime) / 1000).toFixed(2)
    message = "passed #{passedTests} tests in #{time} seconds"
    return console.log(message) unless failures.length
    console.log "failed #{failures.length} and #{message}"
    for fail in failures
      {error, filename}  = fail
      jsFilename         = filename.replace(/\.coffee$/,'.js')
      match              = error.stack?.match(new RegExp(fail.file+":(\\d+):(\\d+)"))
      match              = error.stack?.match(/on line (\d+):/) unless match
      [match, line, col] = match if match
      console.log ''
      console.log "  #{error.description}"
      console.log "  #{error.stack}"
      console.log "  #{jsFilename}: line #{line ? 'unknown'}, column #{col ? 'unknown'}"
      console.log "  #{error.source}" if error.source
    return

  # Run every test in the `test` folder, recording failures.
  files = fs.readdirSync 'test'
  for file in files when file.match /\.coffee$/i
    currentFile = filename = path.join 'test', file
    code = fs.readFileSync filename
    try
      CoffeeScript.run code.toString(), {filename}
    catch error
      failures.push {filename, error}
  return !failures.length
