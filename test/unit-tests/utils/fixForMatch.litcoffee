# For fakes, certain fields change depending on the root directory the
# test is run within. For those fields it is useful to "zero" them out
# to the same value so that the other fields can be tested for equality.

    typeIsArray = require('./typeIsArray')
    typeIsObject = require('./typeIsObject')
    fixForDeepEqual = (response, valuesToFake) ->
      result = {}
      for k,v of response
        if k in valuesToFake
          result[k] = "force matched"
        else if typeIsObject(v)
          result[k] = fixForDeepEqual(v, valuesToFake)
        else if typeIsArray(v)
          for i,l in v
            v[i] = fixForDeepEqual(l, valuesToFake)
          result[k] = v
        else
          result[k] = v
      return result

    module.exports = fixForDeepEqual