Build out the appropriate matchers and delimiters for each language.

    buildMatchers = (languages) ->
      for ext, l of languages

Does the line begin with a comment?

        l.commentMatcher = ///^\s*#{l.symbol}\s?///

Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_%28Unix%29) and interpolations...

        l.commentFilter = /(^#![/]|^\s*#\{)/

Look for links if necessary.

        if l.link
          l.linkMatcher = ///^#{l.link}\[(.+)\]\((.+)\)///

Look for explict section breaks

        if l.section
          l.sectionMatcher = ///^#{l.section}\s?///

      languages

    module.exports = buildMatchers
