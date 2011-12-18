(function() {
  var destination, docco_styles, docco_template, ensure_directory, entitify, exec, ext, fs, generate_documentation, generate_html, get_language, highlight_end, highlight_pygments, highlight_start, highlight_webservice, l, languages, parse, path, preprocess, pygments_installed, request, showdown, sources, spawn, template, _ref;

  fs = require("fs");

  path = require("path");

  showdown = require("./../vendor/showdown").Showdown;

  request = require("http").request;

  _ref = require("child_process"), spawn = _ref.spawn, exec = _ref.exec;

  generate_documentation = function(source, callback) {
    return fs.readFile(source, "utf-8", function(error, code) {
      var sections;
      if (error) throw error;
      sections = parse(source, code);
      return (pygments_installed ? highlight_pygments : highlight_webservice)(source, sections, function() {
        generate_html(source, sections);
        return callback();
      });
    });
  };

  parse = function(source, code) {
    var code_text, docs_text, has_code, language, line, lines, save, sections, _i, _len;
    lines = code.split("\n");
    sections = [];
    language = get_language(source);
    has_code = docs_text = code_text = "";
    save = function(docs, code) {
      return sections.push({
        docs_text: docs,
        code_text: code
      });
    };
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      if (line.match(language.comment_matcher) && !line.match(language.comment_filter)) {
        if (has_code) {
          save(docs_text, code_text);
          has_code = docs_text = code_text = "";
        }
        docs_text += line.replace(language.comment_matcher, "") + "\n";
      } else {
        has_code = true;
        code_text += line + "\n";
      }
    }
    save(docs_text, code_text);
    return sections;
  };

  pygments_installed = (function() {
    var index, path, permissions, _i, _len, _ref2;
    _ref2 = process.env.PATH.split(":");
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      path = _ref2[_i];
      try {
        permissions = fs.statSync("" + path + "/pygmentize").mode.toString(8).slice(-3);
        for (index = 0; index <= 3; index++) {
          if (permissions.charAt(index) % 2 === 1) return true;
        }
      } catch (_error) {}
    }
    return false;
  })();

  highlight_pygments = function(source, sections, callback) {
    var exception, language, output, pygments, section;
    language = get_language(source);
    pygments = spawn("pygmentize", ["-l", language.name, "-f", "html", "-O", "encoding=utf-8,tabsize=2"]);
    output = "";
    exception = function() {
      console.warn("Warning: Pygments encountered an error while highlighting the source code.");
      return preprocess(null, sections, results, callback);
    };
    pygments.stderr.addListener("data", exception);
    pygments.stdin.addListener("error", exception);
    pygments.stdout.addListener("data", function(result) {
      if (result) return output += result;
    });
    pygments.addListener("exit", function() {
      return preprocess(language, sections, output, callback);
    });
    if (pygments.stdin.writable) {
      pygments.stdin.write(((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = sections.length; _i < _len; _i++) {
          section = sections[_i];
          _results.push(section.code_text);
        }
        return _results;
      })()).join(language.divider_text));
      return pygments.stdin.end();
    }
  };

  entitify = function(value) {
    var index, results, _ref2;
    results = "";
    for (index = 0, _ref2 = value.length; 0 <= _ref2 ? index < _ref2 : index > _ref2; 0 <= _ref2 ? index++ : index--) {
      results += "&#x" + (value.charCodeAt(index).toString(16)) + ";";
    }
    return results;
  };

  preprocess = function(language, sections, results, callback) {
    var fragments, index, section, _len;
    if (language != null) {
      fragments = results.replace(highlight_start, "").replace(highlight_end, "").split(language.divider_html);
    } else {
      fragments = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = sections.length; _i < _len; _i++) {
          section = sections[_i];
          _results.push(entitify(section.code_text));
        }
        return _results;
      })();
    }
    for (index = 0, _len = sections.length; index < _len; index++) {
      section = sections[index];
      section.code_html = highlight_start + fragments[index] + highlight_end;
      section.docs_html = showdown.makeHtml(section.docs_text);
    }
    return callback();
  };

  highlight_webservice = function(source, sections, callback) {
    var language, results, section, transport;
    console.warn("Warning: Pygments is not installed. The web service will be used instead.");
    language = get_language(source);
    results = "";
    transport = request({
      host: "pygments.appspot.com",
      method: "post"
    }, function(response) {
      response.setEncoding("utf-8");
      response.on("data", function(chunk) {
        return results += chunk;
      });
      return response.on("end", function() {
        var _ref2;
        if (!((200 <= (_ref2 = response.statusCode) && _ref2 < 300))) {
          language = null;
          console.warn("Warning: The Pygments web service encountered an error.");
        }
        return preprocess(language, sections, results, callback);
      });
    });
    transport.write("lang=" + (encodeURIComponent(language.name)) + "&code=" + (encodeURIComponent(((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = sections.length; _i < _len; _i++) {
        section = sections[_i];
        _results.push(section.code_text);
      }
      return _results;
    })()).join(language.divider_text))));
    transport.on("error", function() {
      console.warn("Warning: The Internet connection is offline.");
      return preprocess(null, sections, results, callback);
    });
    return transport.end();
  };

  generate_html = function(source, sections) {
    var dest, html, title;
    title = path.basename(source);
    dest = destination(source);
    html = docco_template({
      title: title,
      sections: sections,
      sources: sources,
      path: path,
      destination: destination
    });
    console.log("docco: " + source + " -> " + dest);
    return fs.writeFile(dest, html);
  };

  languages = {
    '.coffee': {
      name: 'coffee-script',
      symbol: '#'
    },
    '.js': {
      name: 'javascript',
      symbol: '//'
    },
    '.rb': {
      name: 'ruby',
      symbol: '#'
    },
    '.py': {
      name: 'python',
      symbol: '#'
    }
  };

  for (ext in languages) {
    l = languages[ext];
    l.comment_matcher = new RegExp('^\\s*' + l.symbol + '\\s?');
    l.comment_filter = new RegExp('(^#![/]|^\\s*#\\{)');
    l.divider_text = '\n' + l.symbol + 'DIVIDER\n';
    l.divider_html = new RegExp('\\n*<span class="c1?">' + l.symbol + 'DIVIDER<\\/span>\\n*');
  }

  get_language = function(source) {
    return languages[path.extname(source)];
  };

  destination = function(filepath) {
    return 'docs/' + path.basename(filepath, path.extname(filepath)) + '.html';
  };

  ensure_directory = function(dir, callback) {
    return exec("mkdir -p " + dir, function() {
      return callback();
    });
  };

  template = function(str) {
    return new Function('obj', 'var p=[],print=function(){p.push.apply(p,arguments);};' + 'with(obj){p.push(\'' + str.replace(/[\r\t\n]/g, " ").replace(/'(?=[^<]*%>)/g, "\t").split("'").join("\\'").split("\t").join("'").replace(/<%=(.+?)%>/g, "',$1,'").split('<%').join("');").split('%>').join("p.push('") + "');}return p.join('');");
  };

  docco_template = template(fs.readFileSync(__dirname + '/../resources/docco.jst').toString());

  docco_styles = fs.readFileSync(__dirname + '/../resources/docco.css').toString();

  highlight_start = '<div class="highlight"><pre>';

  highlight_end = '</pre></div>';

  sources = process.ARGV.sort();

  if (sources.length) {
    ensure_directory('docs', function() {
      var files, next_file;
      fs.writeFile('docs/docco.css', docco_styles);
      files = sources.slice(0);
      next_file = function() {
        if (files.length) return generate_documentation(files.shift(), next_file);
      };
      return next_file();
    });
  }

}).call(this);
