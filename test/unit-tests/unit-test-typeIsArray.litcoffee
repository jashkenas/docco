#

    chai = require('chai')
    expect = chai.expect
    should = chai.should()
    assert = chai.assert

    typeIsArray = require('./utils/typeIsArray')

    describe 'test typeIsArray', () ->

      it 'given array, says it is an array', () ->
        x=[1,2,'3']
        typeIsArray(x).should.be.equal(true)

      it 'given object, says it is NOT an array', () ->
        x={a:1,b:2,c:3}
        typeIsArray(x).should.be.equal(false)

      it 'given object with array field, says it is NOT an array', () ->
        x={a:[1],b:[2],c:[3]}
        typeIsArray(x).should.be.equal(false)

      it 'given string, says it is NOT an array', () ->
        x="hi"
        typeIsArray(x).should.be.equal(false)

      it 'given number, says it is NOT an array', () ->
        x=1
        typeIsArray(x).should.be.equal(false)

      it 'given boolean, says it is NOT an array', () ->
        x=true
        typeIsArray(x).should.be.equal(false)

