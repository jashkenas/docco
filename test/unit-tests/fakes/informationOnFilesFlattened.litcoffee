A fake for the flattended getInformationOnFiles test.

    module.exports = {
      "README.md": {
        "destination": {
          "base": "README.html"
          "css": "docco.css"
          "dir": "docs"
          "ext": ".html"
          "file": "docs/README.html"
          "name": "README"
          "path": "/Project/docs/README.html"
          "pathdir": "/Project/docs"
          "relativefile": "README.html"
          "root": "/Project"
        }
        "language": {
          "code": "\\`\\`\\`"
          "codeMatcher": /^\s*\`\`\`/
          "commentFilter": /(^#![\/]|^\s*#\{)/
          "commentMatcher": /^\s*\s?/
          "html": true
          "imageMatcher": /^!\[(.+)\]\((.+)\)/,
          "link": "!",
          "linkMatcher": /^\[(.+)\]\((.+)\)/,
          "name": "markdown"
          "section": "#"
          "sectionMatcher": /^#\s?/
          "symbol": ""
        }
        "others": {
          "README.html": {
            "file": "README.md"
            "image": false
            "link": "README.html"
          }
          "fake_coffee.html": {
            "file": "src/fake_coffee.coffee"
            "image": false
            "link": "fake_coffee.html"
          }
          "fake_litcoffee.html": {
            "file": "src/lib/fake_litcoffee.litcoffee"
            "image": false
            "link": "fake_litcoffee.html"
          }
          "fluffybunny1.jpg": {
            "file": "images/fluffybunny1.jpg"
            "image": true
            "link": "images/fluffybunny1.jpg"
          }
        }
        "source": {
          "base": "README.md"
          "dir": ""
          "ext": ".md"
          "file": "README.md"
          "name": "README"
          "path": "/Project/README.md"
          "relativefile": "README.md"
          "root": "/Project"
        }
      }
      "images/fluffybunny1.jpg": {
        "destination": {
          "base": "fluffybunny1.jpg"
          "css": "../docco.css"
          "dir": "docs/images"
          "ext": ".jpg"
          "file": "docs/images/fluffybunny1.jpg"
          "name": "fluffybunny1"
          "path": "/Project/docs/images/fluffybunny1.jpg"
          "pathdir": "/Project/docs/images"
          "relativefile": "images/fluffybunny1.jpg"
          "root": "/Project"
        }
        "language": {
          "commentFilter": /(^#![\/]|^\s*#\{)/
          "commentMatcher": /^\s*undefined\s?/
          "copy": true
          "name": "image"
        }
        "others": {
          "README.html": {
            "file": "README.md"
            "image": false
            "link": "README.html"
          }
          "fake_coffee.html": {
            "file": "src/fake_coffee.coffee"
            "image": false
            "link": "fake_coffee.html"
          }
          "fake_litcoffee.html": {
            "file": "src/lib/fake_litcoffee.litcoffee"
            "image": false
            "link": "fake_litcoffee.html"
          }
          "fluffybunny1.jpg": {
            "file": "images/fluffybunny1.jpg"
            "image": true
            "link": "images/fluffybunny1.jpg"
          }
        }
        "source": {
          "base": "fluffybunny1.jpg"
          "dir": "images"
          "ext": ".jpg"
          "file": "images/fluffybunny1.jpg"
          "name": "fluffybunny1"
          "path": "/Project/images/fluffybunny1.jpg"
          "relativefile": "fluffybunny1.jpg"
          "root": "/Project"
        }
      }
      "src/fake_coffee.coffee": {
        "destination": {
          "base": "fake_coffee.html"
          "css": "docco.css"
          "dir": "docs"
          "ext": ".html"
          "file": "docs/fake_coffee.html"
          "name": "fake_coffee"
          "path": "/Project/docs/fake_coffee.html"
          "pathdir": "/Project/docs"
          "relativefile": "fake_coffee.html"
          "root": "/Project"
        }
        "language": {
          "commentFilter": /(^#![\/]|^\s*#\{)/
          "commentMatcher": /^\s*#\s?/
          "multiline": {
            "start": "###"
            "stop": "###"
          }
          "name": "coffeescript"
          "startMatcher": /^\s*\#\#\#/
          "stopMatcher": /^\s*\#\#\#/
          "symbol": "#"
        }
        "others": {
          "README.html": {
            "file": "README.md"
            "image": false
            "link": "README.html"
          }
          "fake_coffee.html": {
            "file": "src/fake_coffee.coffee"
            "image": false
            "link": "fake_coffee.html"
          }
          "fake_litcoffee.html": {
            "file": "src/lib/fake_litcoffee.litcoffee"
            "image": false
            "link": "fake_litcoffee.html"
          }
          "fluffybunny1.jpg": {
            "file": "images/fluffybunny1.jpg"
            "image": true
            "link": "images/fluffybunny1.jpg"
          }
        }
        "source": {
          "base": "fake_coffee.coffee"
          "dir": "src"
          "ext": ".coffee"
          "file": "src/fake_coffee.coffee"
          "name": "fake_coffee"
          "path": "/Project/src/fake_coffee.coffee"
          "relativefile": "fake_coffee.coffee"
          "root": "/Project"
        }
      }
      "src/lib/fake_litcoffee.litcoffee": {
        "destination": {
          "base": "fake_litcoffee.html"
          "css": "docco.css"
          "dir": "docs"
          "ext": ".html"
          "file": "docs/fake_litcoffee.html"
          "name": "fake_litcoffee"
          "path": "/Project/docs/fake_litcoffee.html"
          "pathdir": "/Project/docs"
          "relativefile": "fake_litcoffee.html"
          "root": "/Project"
        }
        "language": {
          "commentFilter": /(^#![\/]|^\s*#\{)/
          "commentMatcher": /^\s*#\s?/
          "literate": true
          "name": "coffeescript"
          "symbol": "#"
        }
        "others": {
          "README.html": {
            "file": "README.md"
            "image": false
            "link": "README.html"
          }
          "fake_coffee.html": {
            "file": "src/fake_coffee.coffee"
            "image": false
            "link": "fake_coffee.html"
          }
          "fake_litcoffee.html": {
            "file": "src/lib/fake_litcoffee.litcoffee"
            "image": false
            "link": "fake_litcoffee.html"
          }
          "fluffybunny1.jpg": {
            "file": "images/fluffybunny1.jpg"
            "image": true
            "link": "images/fluffybunny1.jpg"
          }
        }
        "source": {
          "base": "fake_litcoffee.litcoffee"
          "dir": "src/lib"
          "ext": ".litcoffee"
          "file": "src/lib/fake_litcoffee.litcoffee"
          "name": "fake_litcoffee"
          "path": "/Project/src/lib/fake_litcoffee.litcoffee"
          "relativefile": "fake_litcoffee.litcoffee"
          "root": "/Project"
        }
      }
    }