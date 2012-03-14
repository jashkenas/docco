# ### Test Basic Docco Usages

{spawn, exec} = require 'child_process'
path          = require 'path'
fs            = require 'fs'

# Determine the testing data path, and make sure it's clean.
test_path     = path.dirname(fs.realpathSync(__filename));
examples_path = path.normalize(path.join(test_path,"/../examples"))

#### Helpers & Setup

# Run a Docco pass, and check that the number of output files
# is equal to what is expected.  We assume there is one CSS file
# that is always copied to the output, so we check that the 
# number of output files is (matched_sources + 1).
test_docco_run = (test_name,sources,options,callback) ->
  dest_path = path.join(test_path,test_name)
  cleanup = (callback) -> exec "rm -rf #{dest_path}", callback
  cleanup ->
    final_options = {output:dest_path}
    final_options[key] = value for key, value of options if options 
    Docco.document(sources,final_options, ->
      # Calculate the number of expected files in the output, and 
      # then the number of files actually found in the output path.
      files       = []
      files       = files.concat(Docco.resolve_source(src)) for src in sources
      expected    = files.length + 1
      found_files = fs.readdirSync(dest_path)
      found       = found_files.length

      # Left in for debugging of test failures
      #console.log "sources: #{files} - #{expected}"
      #console.log "files: #{found_files} - #{found}"
        
            
      # Make sure to invoke `cleanup()` before checking the result, so
      # the the output path is cleaned, even if the assertion fails
      # for the current test.
      cleanup ->       
        # Check the expected number of files against the number of
        # files that were actually found.
        eq found, expected, 'find expected output'
        
        # Trigger the completion callback if it's specified
        callback() if callback?
    )

#### Documenting Docco

# Check to be sure Docco can document itself, and produce the 
# expected output.  This exercises the no options branches of
# logic.  
test "documenting Docco", ->
  docs_path = path.normalize("#{test_path}/../docs/")
  sources   = path.normalize("#{test_path}/../src/*.coffee")

  # We need to remove the docs/ directory to ensure it contains
  # no files.  If it contains files when this test is run, the 
  # assertion checks could be compromised, making the test itself
  # quite britle.
  exec "rm -rf #{docs_path}", ->
    Docco.document([sources],null, ->
        found_files = fs.readdirSync(docs_path)
        found       = found_files.length
        files       = Docco.resolve_source(sources)
        expected    = files.length + 1

        # Left in for debugging of test failures
        #console.log "sources: #{files} - #{expected}"
        #console.log "files: #{found_files} - #{found}"

        # Check the expected number of files against the number of
        # files that were actually found.
        eq found, expected, 'find docco expected output'
    )

#### Docco with non-default options

# Run with just a custom jst template, and verify that the 
# expected output is found.
test "custom templates and css files", ->
  
  # Use the pagelet example for testing.
  pagelet   = "#{examples_path}/pagelet/pagelet"
  tests = [
    # Use a custom jst template file path
    {
      name:"custom_template_coffee",
      sources:["#{examples_path}/basic/*"],
      options:{template: "#{pagelet}.jst"}
    },
    # Use a custom CSS file path
    {
      name:"custom_css_js",
      sources:["#{examples_path}/basic/*"],
      options:{css: "#{pagelet}.css"}
    },
  ]
  next_test = ->
    docco_test = tests.shift()
    test_docco_run docco_test.name, docco_test.sources,docco_test.options, next_test if tests.length
  next_test()
    
