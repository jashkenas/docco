# This tests if buildMatchers is working correctly.

    { assert, should } = require('chai'); should()
    buildMatchers = require '../../src/buildMatchers'
    {languages} = require('../../docco')

    describe 'docco buildMatchers', () ->

      it 'buildMatchers some source code', () ->

        languages = buildMatchers(languages)
        for ext, l of languages
          assert.deepEqual(l.commentMatcher,///^\s*#{l.symbol}\s?///)
          assert.deepEqual(l.commentFilter,/(^#![/]|^\s*#\{)/)
          if l.link
            assert.deepEqual(l.linkMatcher,///^\[(.+)\]\((.+)\)///)
          if l.section
            assert.deepEqual(l.sectionMatcher,///^#{l.section}\s?///)
      return
    return