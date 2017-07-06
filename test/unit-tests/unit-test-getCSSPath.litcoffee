# This tests if getCSSPath is working correctly

    { should } = require('chai'); should()
    getCSSPath = require('../../src/getCSSPath')

    describe 'docco getCSSPath', () ->


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
