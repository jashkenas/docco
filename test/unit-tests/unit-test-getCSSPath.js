var getCSSPath, should;

should = require('chai').should;

should();

getCSSPath = require('../../src/getCSSPath');

describe('docco getCSSPath', function() {
  it('gets the path to the css in the same directory.', function() {
    var cssPath;
    cssPath = getCSSPath('file.css', 'docs', 'docs/file.html');
    cssPath.should.be.equal('file.css');
  });
  it('gets the path to the css in directory above.', function() {
    var cssPath;
    cssPath = getCSSPath('file.css', 'docs', 'docs/src/file.html');
    cssPath.should.be.equal('../file.css');
  });
  it('gets the path to the css in two directories above.', function() {
    var cssPath;
    cssPath = getCSSPath('file.css', 'docs', 'docs/src/lib/file.html');
    cssPath.should.be.equal('../../file.css');
  });
  it('gets the path to the css in in parallel directory.', function() {
    var cssPath;
    cssPath = getCSSPath('docs/file.css', 'docs', 'src/file.html');
    cssPath.should.be.equal('../docs/file.css');
  });
});

//# sourceMappingURL=unit-test-getCSSPath.js.map
