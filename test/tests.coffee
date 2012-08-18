
{spawn, exec} = require 'child_process'
path          = require 'path'
fs            = require 'fs'

# Determine the test and resources paths
testPath      = path.dirname fs.realpathSync(__filename)
dataPath      = path.join testPath, "data"
resourcesPath = path.normalize path.join(testPath,"/../resources")

#### Docco Test Assertion Wrapper 

# Run a Docco pass, and check that the number of output files
# is equal to what is expected.  We assume there is one CSS file
# that is always copied to the output, so we check that the 
# number of output files is (matched_sources + 1).
testDoccoRun = (test_name,sources,options=null,callback=null) ->
  destPath = path.join dataPath, test_name
  # Remove the data directory for this test run
  cleanup = (callback) -> exec "rm -rf #{destPath}", callback
  cleanup ->
    options?.output = destPath
    Docco.document sources, options, ->
      # Calculate the number of expected files in the output, and 
      # then the number of files actually found in the output path.
      files       = []
      files       = files.concat(Docco.resolveSource(src)) for src in sources
      expected    = files.length + 1
      found       = fs.readdirSync(destPath).length
           
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
  docsPath = path.normalize("#{testPath}/../docs")
  sources   = ["#{testPath}/../src/docco.coffee","#{testPath}/tests.coffee"]

  # We need to remove the docs/ directory to ensure it contains
  # no files.  If it contains files when this test is run, the 
  # assertion checks could be compromised, making the test itself
  # quite britle.
  exec "rm -rf #{docsPath}", ->
    Docco.document sources,null, ->
      found       = fs.readdirSync(docsPath).length
      files       = []
      files       = files.concat(Docco.resolveSource(src)) for src in sources
      expected    = files.length + 1
      eq found, expected, 'find docco expected output'

#### Docco with non-default options

# Verify we can use a custom jst template file
test "custom JST template file", ->
  testDoccoRun "custom_jst", 
    ["#{testPath}/*.coffee"],
    template: "#{resourcesPath}/pagelet.jst"

# Verify we can use a custom CSS file
test "custom CSS file", ->
  testDoccoRun "custom_css", 
    ["#{testPath}/*.coffee"],
    css: "#{resourcesPath}/pagelet.css"

# Issue 100: Verify that URL references work across doc and code sections.
test "url references", ->
  exec "mkdir -p #{dataPath}", ->
    sourceFile = "#{testPath}/data/_urlref.coffee"
    fs.writeFileSync sourceFile, """
    # Look at this link to [Google][]! 
    console.log 'This must be Thursday.'
    # And this link to [Google][] as well.
    console.log 'I never could get the hang of Thursdays.'
    # [google]: http://www.google.com
    """
    outPath = "#{testPath}/data/_urlreferences"
    outFile = "#{outPath}/_urlref.html"
    exec "rm -rf #{outPath}", ->
      Docco.document [sourceFile], output: outPath, ->
        contents = fs.readFileSync(outFile).toString()
        count = contents.match ///<a\shref="http://www.google.com">Google</a>///g
        eq count.length, 2, "find expected (2) resolved url references"

#### Docco Comment Parser

# Verify we can parse expected comments from each supported language.
test "single line comment parsing", ->
  commentsPath = path.join testPath, "comments"
  options =
    template: "#{commentsPath}/comments.jst"

  # Construct a list of languages to test asynchronously.  It's important
  # that these be tested one at a time, to avoid conflicts between multiple
  # file extensions for a language.  e.g. `c.c` and `c.h` both output to 
  # c.html, so they must be run at separate times.
  languageKeys = (ext for ext,l of Docco.languages)

  testNextLanguage = (keys,callback) ->
    # We're all done here.
    return callback?() if not keys.length

    ext = keys.shift()
    l = Docco.languages[ext]

    languageExample = path.join commentsPath, "#{l.name}#{ext}"
    languageTest    = "comments_test/#{l.name}"
    languagePath    = path.join dataPath, languageTest

    # Skip over this language if there is no corresponding test.
    return testNextLanguage(keys, callback) if not path.existsSync languageExample   
   
    # Run them through docco with the custom `comments.jst` file that 
    # outputs a CSV list of doc blocks text.    
    testDoccoRun languageTest, [languageExample], options, ->
  
      # Be sure the expected output file exists
      languageOutput = path.join languagePath, "#{l.name}.html"
      eq true, path.existsSync(languageOutput), "#{languageOutput} -> output file created properly"

      # Read in the output file contents, split them into a list
      # of comments.
      content = fs.readFileSync(languageOutput).toString()
      comments = (c.trim() for c in content.split(',') when c.trim() != '') 
      eq true, comments.length >= 1, 'expect at least the descriptor comment'

      # Parse the first comment (special case), to identify the expected comment count
      expected = parseInt(comments[0])    
      eq comments.length, expected, [
        ""
        "#{path.basename(languageOutput)} comments"
        "------------------------"
        " expected : #{expected}"
        " found    : #{comments.length}"
      ].join '\n'
      
      # Invoke the next test
      testNextLanguage keys, callback
      
  # Kick off the first language test.
  testNextLanguage languageKeys.slice(), ->
    # Test to be sure block comments are excluded when not explicitly
    # specified.  In this case, the test will check for the existence 
    # of only 1 comment in all languages (a single-line)
    options.blocks = false
    testNextLanguage languageKeys.slice()
    
