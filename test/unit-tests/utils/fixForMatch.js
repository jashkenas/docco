var fixForDeepEqual, typeIsArray, typeIsObject,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

typeIsArray = require('./typeIsArray');

typeIsObject = require('./typeIsObject');

fixForDeepEqual = function(response, valuesToFake) {
  var i, j, k, l, len, result, v;
  result = {};
  for (k in response) {
    v = response[k];
    if (indexOf.call(valuesToFake, k) >= 0) {
      result[k] = "force matched";
    } else if (typeIsObject(v)) {
      result[k] = fixForDeepEqual(v, valuesToFake);
    } else if (typeIsArray(v)) {
      for (l = j = 0, len = v.length; j < len; l = ++j) {
        i = v[l];
        v[i] = fixForDeepEqual(l, valuesToFake);
      }
      result[k] = v;
    } else {
      result[k] = v;
    }
  }
  return result;
};

module.exports = fixForDeepEqual;

//# sourceMappingURL=fixForMatch.js.map
