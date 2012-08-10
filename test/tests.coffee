
{spawn, exec} = require 'child_process'
path          = require 'path'
fs            = require 'fs'

# Determine the test and resources paths
test_path      = path.dirname fs.realpathSync(__filename)
data_path      = path.join test_path, "data"
resources_path = path.normalize path.join(test_path,"/../resources")

#### Docco Test Assertion Wrapper 

# Run a Docco pass, and check that the number of output files
# is equal to what is expected.  We assume there is one CSS file
# that is always copied to the output, so we check that the 
# number of output files is (matched_sources + 1).
test_docco_run = (test_name,sources,options=null,callback=null) ->
  dest_path = path.join data_path, test_name
  # Remove the data directory for this test run
  cleanup = (callback) -> exec "rm -rf #{dest_path}", callback
  cleanup ->
    options?.output = dest_path
    Docco.document sources, options, ->
      # Calculate the number of expected files in the output, and 
      # then the number of files actually found in the output path.
      files       = []
      files       = files.concat(Docco.resolveSource(src)) for src in sources
      expected    = files.length + 1
      found       = fs.readdirSync(dest_path).length
           
      # Check the expected number of files against the number of
      # files that were actually found.
      eq found, expected, "find expected output (#{expected} files) - (#{found})"
      
      # Trigger the completion callback if it's specified
      callback() if callback?

#### Documenting Docco

# Check to be sure Docco can document itself, and produce the 
# expected output.  This exercises the no options branches of
# logic.  
test "documenting Docco", ->
  docs_path = path.normalize("#{test_path}/../docs")
  sources   = ["#{test_path}/../src/docco.coffee","#{test_path}/tests.coffee"]

  # We need to remove the docs/ directory to ensure it contains
  # no files.  If it contains files when this test is run, the 
  # assertion checks could be compromised, making the test itself
  # quite britle.
  exec "rm -rf #{docs_path}", ->
    Docco.document sources,null, ->
      found       = fs.readdirSync(docs_path).length
      files       = []
      files       = files.concat(Docco.resolveSource(src)) for src in sources
      expected    = files.length + 1
      eq found, expected, 'find docco expected output'

#### Docco with non-default options

# Verify we can use a custom jst template file
test "custom JST template file", ->
  test_docco_run "custom_jst", 
    ["#{test_path}/*.coffee"],
    template: "#{resources_path}/pagelet.jst"

# Verify we can use a custom CSS file
test "custom CSS file", ->
  test_docco_run "custom_css", 
    ["#{test_path}/*.coffee"],
    css: "#{resources_path}/pagelet.css"

#### Docco Comment Parser

# Verify we can parse expected comments from each supported language.
test "single and block comment parsing", ->
  comments_path = path.join test_path, "comments"
  options =
    template: "#{comments_path}/comments.jst"
    blocks  : true  

  # Construct a list of languages to test asynchronously.  It's important
  # that these be tested one at a time, to avoid conflicts between multiple
  # file extensions for a language.  e.g. `c.c` and `c.h` both output to 
  # c.html, so they must be run at separate times.
  language_keys = (ext for ext,l of Docco.languages)

  test_next_language = (keys,callback) ->
    # We're all done here.
    return callback?() if not keys.length

    ext = keys.shift()
    l = Docco.languages[ext]

    language_example = path.join comments_path, "#{l.name}#{ext}"
    language_test    = "comments_test/#{l.name}"
    language_path    = path.join data_path, language_test

    # Skip over this language if there is no corresponding test.
    return test_next_language(keys, callback) if not path.existsSync language_example   
   
    # Run them through docco with the custom `comments.jst` file that 
    # outputs a CSV list of doc blocks text.    
    test_docco_run language_test, [language_example], options, ->
  
      # Be sure the expected output file exists
      language_output = path.join language_path, "#{l.name}.html"
      eq true, path.existsSync(language_output), "#{language_output} -> output file created properly"

      # Read in the output file contents, split them into a list
      # of comments.
      content = fs.readFileSync(language_output).toString()
      comments = (c.trim() for c in content.split(',') when c.trim() != '') 
      eq true, comments.length >= 1, 'expect at least the descriptor comment'

      # Parse the first comment (special case), to identify the expected 
      # comment counts, based on whether we're matching block comments or not.
      descriptor = comments[0].match(/^Single:([0-9]*) - Block:([0-9]*)$/)
      expected = parseInt(if l.blocks and options.blocks then descriptor[2] else descriptor[1])    
      eq comments.length, expected, [
        ""
        "#{path.basename(language_output)} comments"
        "------------------------"
        " blocks   : #{options.blocks}"
        " expected : #{expected}"
        " found    : #{comments.length}"
      ].join '\n'
      
      # Invoke the next test
      test_next_language keys, callback
      
  # Kick off the first language test.
  test_next_language language_keys.slice(), ->
    # Test to be sure block comments are excluded when not explicitly
    # specified.  In this case, the test will check for the existence 
    # of only 1 comment in all languages (a single-line)
    options.blocks = false
    test_next_language language_keys.slice()
    
