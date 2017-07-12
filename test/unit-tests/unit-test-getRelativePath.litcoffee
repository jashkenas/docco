# This tests if getLanguage is working correctly.

    { should } = require('chai'); should()
    getRelativePath = require('../../src/getRelativePath')

    describe 'docco getRelativePath', () ->

      it 'gets the path to a file in the same directory.', () ->
        cssPath = getRelativePath('./file.css', './file.html', 'file.html' )
        cssPath.should.be.equal('file.html')
        return

      it 'gets the path to a file in directory above.', () ->
        cssPath = getRelativePath('file.css', 'docs/file.html', 'file.html' )
        cssPath.should.be.equal('docs/file.html')
        return

      it 'gets the path to a file in two directories above.', () ->
        cssPath = getRelativePath('file.css', 'docs/src/lib/file.html', 'file.html')
        cssPath.should.be.equal('docs/src/lib/file.html')
        return

      it 'gets the path to a file in parallel directory.', () ->
        cssPath = getRelativePath('docs/file.css', 'src/file.html' ,'file.html')
        cssPath.should.be.equal('../src/file.html')
        return

      it 'gets the path to the same file.', () ->
        cssPath = getRelativePath('docs/file.html', 'docs/file.html', 'file.html')
        cssPath.should.be.equal('file.html')
        return
      return
