var getRelativePath, should;

should = require('chai').should;

should();

getRelativePath = require('../../src/getRelativePath');

describe('docco getRelativePath', function() {
  it('gets the path to a file in the same directory.', function() {
    var cssPath;
    cssPath = getRelativePath('./file.css', './file.html', 'file.html');
    cssPath.should.be.equal('file.html');
  });
  it('gets the path to a file in directory above.', function() {
    var cssPath;
    cssPath = getRelativePath('file.css', 'docs/file.html', 'file.html');
    cssPath.should.be.equal('docs/file.html');
  });
  it('gets the path to a file in two directories above.', function() {
    var cssPath;
    cssPath = getRelativePath('file.css', 'docs/src/lib/file.html', 'file.html');
    cssPath.should.be.equal('docs/src/lib/file.html');
  });
  it('gets the path to a file in parallel directory.', function() {
    var cssPath;
    cssPath = getRelativePath('docs/file.css', 'src/file.html', 'file.html');
    cssPath.should.be.equal('../src/file.html');
  });
  it('gets the path to the same file.', function() {
    var cssPath;
    cssPath = getRelativePath('docs/file.html', 'docs/file.html', 'file.html');
    cssPath.should.be.equal('file.html');
  });
});

//# sourceMappingURL=unit-test-getRelativePath.js.map
