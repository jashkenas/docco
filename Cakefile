{spawn, exec} = require 'child_process'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'build', 'continually build the docco library with --watch', ->
  coffee = spawn 'coffee', ['-cw', '-o', 'lib', 'src']
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
