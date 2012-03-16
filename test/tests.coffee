
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
  # Remove the data directory for this test run, called before and
  # after a test.
  cleanup = (callback) -> exec "rm -rf #{dest_path}", callback
  cleanup ->
    options?.output = dest_path
    Docco.document sources, options, ->
      # Calculate the number of expected files in the output, and 
      # then the number of files actually found in the output path.
      files       = []
      files       = files.concat(Docco.resolve_source(src)) for src in sources
      expected    = files.length + 1
      found       = fs.readdirSync(dest_path).length
           
      # Check the expected number of files against the number of
      # files that were actually found.
      eq found, expected, 'find expected output'
      
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
      files       = files.concat(Docco.resolve_source(src)) for src in sources
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
  sources = []
  options =
    template: "#{comments_path}/comments.jst"
    blocks  : true  

  # Construct a list of sources from `Docco.languages`
  for ext,l of Docco.languages
    language_example = path.join comments_path, "#{l.name}#{ext}" 
    sources.push language_example if path.existsSync language_example
    
  # Run them through docco with the custom `comments.jst` file that 
  # outputs a newline character per doc section generated.  Each lanuage
  # example contains two comments (a single and block comment, or two single 
  # comments in the case of a language that does not support block comments.)
  test_docco_run "comments_test", sources, options

  # Iterate over the outputs, and ensure they all contain 2 entries
  for ext,l of Docco.languages
    language_output = path.join data_path, "comments_test/#{l.name}.html"
    continue if not path.existsSync language_output
    content = fs.readFileSync(language_output).toString().replace(/\n/,'')
    comment_count = content.match /\s*<p>\s*(Comment)\s*<\/p>\s*/gi 
    eq comment_count.length, 2, "find two comments"
