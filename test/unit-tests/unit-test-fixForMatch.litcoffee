#

    chai = require('chai')
    expect = chai.expect
    should = chai.should()
    assert = chai.assert

    fixForMatch = require('./utils/fixForMatch')

    describe 'fix for match', () ->

      replacement = "force matched"
      it 'zeros out particular fields..', () ->
        object = {
          thingId: "1234"
          thing1: {
            thingId: "1234"

          }
          thing2: [{ tin: {id: 1}},{ tin: {id: 2}}]
          leadTime: 3
          transitTime: 3
        }
        result = fixForMatch(object,['thingId', 'leadTime', 'transitTime', 'id'])
        result.thingId.should.be.equal(replacement)
        result.leadTime.should.be.equal(replacement)
        result.transitTime.should.be.equal(replacement)
        result.thing1.thingId.should.be.equal(replacement)
        result.thing2[0].tin.id.should.be.equal(replacement)
        result.thing2[1].tin.id.should.be.equal(replacement)

        return
