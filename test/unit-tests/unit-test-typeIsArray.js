var assert, chai, expect, should, typeIsArray;

chai = require('chai');

expect = chai.expect;

should = chai.should();

assert = chai.assert;

typeIsArray = require('./utils/typeIsArray');

describe('test typeIsArray', function() {
  it('given array, says it is an array', function() {
    var x;
    x = [1, 2, '3'];
    return typeIsArray(x).should.be.equal(true);
  });
  it('given object, says it is NOT an array', function() {
    var x;
    x = {
      a: 1,
      b: 2,
      c: 3
    };
    return typeIsArray(x).should.be.equal(false);
  });
  it('given object with array field, says it is NOT an array', function() {
    var x;
    x = {
      a: [1],
      b: [2],
      c: [3]
    };
    return typeIsArray(x).should.be.equal(false);
  });
  it('given string, says it is NOT an array', function() {
    var x;
    x = "hi";
    return typeIsArray(x).should.be.equal(false);
  });
  it('given number, says it is NOT an array', function() {
    var x;
    x = 1;
    return typeIsArray(x).should.be.equal(false);
  });
  return it('given boolean, says it is NOT an array', function() {
    var x;
    x = true;
    return typeIsArray(x).should.be.equal(false);
  });
});

//# sourceMappingURL=unit-test-typeIsArray.js.map
