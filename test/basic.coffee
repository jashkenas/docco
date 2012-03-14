# ### Test Basic Docco Usages

{spawn, exec} = require 'child_process'
path          = require 'path'
fs            = require 'fs'

# Determine the testing data path, and make sure it's clean.
test_path     = path.dirname(fs.realpathSync(__filename));
examples_path = path.normalize(path.join(test_path,"/../examples"))

# Ensure that a directory exists.
ensure_directory = (dir, callback) ->
  exec "mkdir -p #{dir}", -> callback()
  
remove_directory = (dir,callback) ->
  exec "rm -rf #{dir}"

# Create and provide a simple way of cleaning up a working directory
# for a test to output its results into.  
#
# `callback` is a callback function (no arguments) that is to 
# be invoked when the handler is done.
create_test_output = (dir,callback) ->
  cleanup = -> remove_directory path.join(test_path,dir)
  ensure_directory path.join(test_path,dir), -> callback(cleanup)

# Check to be sure Docco can document itself, and produce the 
# expected output.  This exercises the no options branches of
# logic.  
test "documenting Docco", ->
  docs_path = path.normalize("#{test_path}/../docs/")
  console.log docs_path
  ensure_directory docs_path, ->
    sources = path.normalize("#{test_path}/../src/")
    Docco.document([sources],{},
      ->
        expected = Docco.resolve_source(sources).length + 1
        found = fs.readdirSync(test_path).length
        eq found, expected, 'found expected output'
    )

# Run with just a custom jst template, and verify that the 
# expected output is found.
test "custom templates and css files", ->
  pagelet = "#{examples_path}/templates/pagelet"
  create_test_output "custom_files", (done)->
    sources = "#{examples_path}/basic/*.coffee"
    Docco.document([sources],{template:"#{pagelet}.jst",output:test_path},
      ->
        expected = Docco.resolve_source(sources).length + 1
        found = fs.readdirSync(test_path).length 
        eq found, expected, 'expected one doc page and the css file'
        done()
    )
