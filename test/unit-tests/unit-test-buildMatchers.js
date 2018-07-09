var assert, buildMatchers, languages, ref, should;

ref = require('chai'), assert = ref.assert, should = ref.should;

should();

buildMatchers = require('../../src/buildMatchers');

languages = require('../../docco').languages;

describe('docco buildMatchers', function() {
  it('buildMatchers some source code', function() {
    var ext, l, results;
    languages = buildMatchers(languages);
    results = [];
    for (ext in languages) {
      l = languages[ext];
      assert.deepEqual(l.commentMatcher, RegExp("^\\s*" + l.symbol + "\\s?"));
      assert.deepEqual(l.commentFilter, /(^#![\/]|^\s*#\{)/); // /(^#![\/]|^\s*#\{)/);
      if (l.link) {
        assert.deepEqual(l.linkMatcher, RegExp("^\\[(.+)\\]\\((.+)\\)"));
      }
      if (l.section) {
        results.push(assert.deepEqual(l.sectionMatcher, RegExp("^" + l.section + "\\s?")));
      } else {
        results.push(void 0);
      }
    }
    return results;
  });
});

return;

//# sourceMappingURL=unit-test-buildMatchers.js.map
