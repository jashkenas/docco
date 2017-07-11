Build out the appropriate matchers and delimiters for each language.

    module.exports = buildMatchers = (languages) ->
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

Look for multiline comments.  The tricky part here is that the characters need to be escaped.


        if l.multiline
          # use replace to insert a '\' in front of every character
          start = l.multiline.start.replace(/(.{1})/g,"\\$1")
          stop = l.multiline.stop.replace(/(.{1})/g,"\\$1")

          l.startMatcher = ///^\s*#{start}///
          l.stopMatcher = ///^\s*#{stop}///

      languages
