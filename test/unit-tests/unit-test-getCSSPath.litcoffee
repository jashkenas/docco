# This tests if getLanguage is working correctly

  #!/usr/bin/env node
  { should } = require('chai'); should()
  describe 'docco getCSSPath', () ->
    { getCSSPath } = require('../../docco')

    it 'gets the path to the css in the same directory.', () ->
      cssPath = getCSSPath('file.css', 'docs', 'docs/file.html' )
      cssPath.should.be.equal('file.css')
      return

    it 'gets the path to the css in directory above.', () ->
      cssPath = getCSSPath('file.css', 'docs', 'docs/src/file.html' )
      cssPath.should.be.equal('../file.css')
      return

    it 'gets the path to the css in two directories above.', () ->
      cssPath = getCSSPath('file.css', 'docs', 'docs/src/lib/file.html' )
      cssPath.should.be.equal('../../file.css')
      return

    it 'gets the path to the css in in parallel directory.', () ->
      cssPath = getCSSPath('docs/file.css', 'docs', 'src/file.html' )
      cssPath.should.be.equal('../docs/file.css')
      return
    return