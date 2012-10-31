
path          = require 'path'
fs            = require 'fs'
rimraf        = require 'rimraf'

# Determine the test and resources paths
testPath      = path.dirname fs.realpathSync(__filename)
dataPath      = path.join testPath, "data"
resourcesPath = path.normalize path.join(testPath,"/../resources")

# Run a Docco pass and check that the number of output files
# is equal to what is expected.
testDoccoRun = (testName,sources,options=null,callback=null) ->
  destPath = path.join dataPath, testName
  cleanup = (callback) -> rimraf destPath, callback
  cleanup (error) ->
    equal not error, true, "path cleaned up properly"
    options?.output = destPath
    Docco.document sources, options, ->
      files       = []
      files       = files.concat(Docco.resolveSource(src)) for src in sources
      expected    = files.length + 1
      found       = fs.readdirSync(destPath).length
      equal found, expected, "find expected output (#{expected} files) - (#{found})"
      callback() if callback?

# **Custom jst template files should be supported**
test "custom JST template file", ->
  testDoccoRun "custom_jst", 
    ["#{testPath}/*.coffee"],
    template: "#{resourcesPath}/pagelet.jst"

# **Custom CSS files should be supported**
test "custom CSS file", ->
  testDoccoRun "custom_css", 
    ["#{testPath}/*.coffee"],
    css: "#{resourcesPath}/pagelet.css"

# **Comments should be parsed properly**
#  
# There are special data files located in `test/comments` for each supported 
# language.  The first comment in  each file corresponds to the expected number 
# of comments to be parsed from its contents.
#  
# This test iterates over all the known Docco languages, and tests the ones 
# that have a corresponding data file in `test/comments`.
test "single line comment parsing", ->
  commentsPath = path.join testPath, "comments"
  options           = template: "#{commentsPath}/comments.jst"
  languageKeys = (ext for ext,l of Docco.languages)

  testNextLanguage = (keys,callback) ->
    return callback?() if not keys.length

    extension       = keys.shift()
    language        = Docco.languages[extension]
    languageExample = path.join commentsPath, "#{language.name}#{extension}"
    languageTest    = "comments_test/#{language.name}"
    languagePath    = path.join dataPath, languageTest
    languageOutput  = path.join languagePath, "#{language.name}.html"

    # *Skip over this language if there is no corresponding test*
    return testNextLanguage(keys, callback) if not path.existsSync languageExample   
   
    testDoccoRun languageTest, [languageExample], options, ->
      equal true, path.existsSync(languageOutput), "#{languageOutput} -> output file created properly"

      content = fs.readFileSync(languageOutput).toString()
      comments = (c.trim() for c in content.split(',') when c.trim() != '') 

      equal true, comments.length >= 1, 'expect at least the descriptor comment'

      expected = parseInt(comments[0])    
      
      equal comments.length, expected, [
        ""
        "#{path.basename(languageOutput)} comments"
        "------------------------"
        " expected : #{expected}"
        " found    : #{comments.length}"
      ].join '\n'
      
      testNextLanguage keys, callback
      
  # *Kick off the first language test*
  testNextLanguage languageKeys.slice()
    
# **URL references should resolve across sections**
#  
# Resolves [Issue 100](https://github.com/jashkenas/docco/issues/100)
test "url references", ->
  Docco.ensureDirectory dataPath, ->
    sourceFile = "#{dataPath}/_urlref.coffee"
    fs.writeFileSync sourceFile, [
      "# Look at this link to [Google][]!",
      "console.log 'This must be Thursday.'",
      "# And this link to [Google][] as well.",
      "console.log 'I never could get the hang of Thursdays.'",
      "# [google]: http://www.google.com"
    ].join('\n')
    outPath = path.join dataPath, "_urlreferences"
    outFile = "#{outPath}/_urlref.html"
    rimraf outPath, (error) ->
      equal not error, true
      Docco.document [sourceFile], output: outPath, ->
        contents = fs.readFileSync(outFile).toString()
        count = contents.match ///<a\shref="http://www.google.com">Google</a>///g
        equal count.length, 2, "find expected (2) resolved url references"

# **Paths should be recursively created if needed**
#  
# ensureDirectory should properly create complex output paths.
test "create complex paths that do not exist", ->
  exist = fs.existsSync or path.existsSync
  outputPath = path.join dataPath, 'complex/path/that/doesnt/exist'
  rimraf outputPath, (error) ->
    equal not error, true
    Docco.ensureDirectory outputPath, ->
      equal exist(outputPath), true, 'created output path'
      stat = fs.statSync outputPath
      equal stat.isDirectory(), true, "target is directory"