{spawn, exec} = require 'child_process'
fs            = require 'fs'
path          = require 'path'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'
option '-w', '--watch', 'continually build the docco library'
option '-l', '--layout [LAYOUT]', 'specify the layout for Docco\'s docs'

task 'build', 'build the docco library', (options) ->
  coffee = spawn 'coffee', ['-c' + (if options.watch then 'w' else ''), '.']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'install', 'install the `docco` command into /usr/local (or --prefix)', (options) ->
  base = options.prefix or '/usr/local'
  lib  = base + '/lib/docco'
  exec([
    'mkdir -p ' + lib
    'cp -rf bin README resources lib ' + lib
    'ln -sf ' + lib + '/bin/docco ' + base + '/bin/docco'
  ].join(' && '), (err, stdout, stderr) ->
   if err then console.error stderr
  )

task 'doc', 'rebuild the Docco documentation', (options) ->
  layout = options.layout or 'linear'
  exec([
    "bin/docco --layout #{layout} docco.litcoffee"
    "sed \"s/docco.css/resources\\/#{layout}\\/docco.css/\" < docs/docco.html > index.html"
    'rm -r docs'
  ].join(' && '), (err) ->
    throw err if err
  )
