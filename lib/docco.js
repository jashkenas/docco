(function() {
  var DEFAULTS, commander, ensure_directory, exec, ext, fs, generate_documentation, generate_html, get_language, highlight, highlight_end, highlight_start, l, languages, parse, path, showdown, spawn, template, version, _ref;

  generate_documentation = function(source, config, callback) {
    return fs.readFile(source, "utf-8", function(error, code) {
      var sections;
      if (error) throw error;
      sections = parse(source, code);
      return highlight(source, sections, function() {
        generate_html(source, sections, config);
        return callback();
      });
    });
  };

  parse = function(source, code) {
    var code_text, docs_text, has_code, language, line, lines, save, sections, _i, _len;
    lines = code.split('\n');
    sections = [];
    language = get_language(source);
    has_code = docs_text = code_text = '';
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
          has_code = docs_text = code_text = '';
        }
        docs_text += line.replace(language.comment_matcher, '') + '\n';
      } else {
        has_code = true;
        code_text += line + '\n';
      }
    }
    save(docs_text, code_text);
    return sections;
  };

  highlight = function(source, sections, callback) {
    var language, output, pygments, section;
    language = get_language(source);
    pygments = spawn('pygmentize', ['-l', language.name, '-f', 'html', '-O', 'encoding=utf-8,tabsize=2']);
    output = '';
    pygments.stderr.addListener('data', function(error) {
      if (error) return console.error(error.toString());
    });
    pygments.stdin.addListener('error', function(error) {
      console.error("Could not use Pygments to highlight the source.");
      return process.exit(1);
    });
    pygments.stdout.addListener('data', function(result) {
      if (result) return output += result;
    });
    pygments.addListener('exit', function() {
      var fragments, i, section, _len;
      output = output.replace(highlight_start, '').replace(highlight_end, '');
      fragments = output.split(language.divider_html);
      for (i = 0, _len = sections.length; i < _len; i++) {
        section = sections[i];
        section.code_html = highlight_start + fragments[i] + highlight_end;
        section.docs_html = new showdown.converter().makeHtml(section.docs_text);
      }
      return callback();
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

  generate_html = function(source, sections, config) {
    var dest, destination, html, title;
    destination = function(filepath) {
      return path.join(config.output, path.basename(filepath, path.extname(filepath)) + '.html');
    };
    title = path.basename(source);
    dest = destination(source);
    html = config.docco_template({
      title: title,
      sections: sections,
      sources: config.sources,
      path: path,
      destination: destination
    });
    console.log("docco: " + source + " -> " + dest);
    return fs.writeFile(dest, html);
  };

  fs = require('fs');

  path = require('path');

  showdown = require('showdown').Showdown;

  _ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;

  commander = require('commander');

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
    },
    '.tex': {
      name: 'tex',
      symbol: '%'
    },
    '.latex': {
      name: 'tex',
      symbol: '%'
    },
    '.c': {
      name: 'c',
      symbol: '//'
    },
    '.h': {
      name: 'c',
      symbol: '//'
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

  ensure_directory = function(dir, callback) {
    return exec("mkdir -p " + dir, function() {
      return callback();
    });
  };

  template = function(str) {
    return new Function('obj', 'var p=[],print=function(){p.push.apply(p,arguments);};' + 'with(obj){p.push(\'' + str.replace(/[\r\t\n]/g, " ").replace(/'(?=[^<]*%>)/g, "\t").split("'").join("\\'").split("\t").join("'").replace(/<%=(.+?)%>/g, "',$1,'").split('<%').join("');").split('%>').join("p.push('") + "');}return p.join('');");
  };

  version = JSON.parse(fs.readFileSync("" + __dirname + "/../package.json")).version;

  DEFAULTS = {
    template: "" + __dirname + "/../resources/docco.jst",
    css: "" + __dirname + "/../resources/docco.css",
    output: "docs/"
  };

  highlight_start = '<div class="highlight"><pre>';

  highlight_end = '</pre></div>';

  exports.resolve_source = function(source) {
    var file, match_files, match_path, match_regex, match_string;
    if (!source.match(/([\*\?])/)) return source;
    match_path = path.dirname(source);
    match_string = path.basename(source).replace(/\./g, "\\$&").replace(/\*/, ".*").replace(/\?/, ".");
    match_regex = new RegExp('(' + match_string + ')');
    match_files = fs.readdirSync(match_path);
    return (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = match_files.length; _i < _len; _i++) {
        file = match_files[_i];
        if (file.match(match_regex)) _results.push(path.join(match_path, file));
      }
      return _results;
    })();
  };

  exports.run = function(args) {
    if (args == null) args = process.argv;
    commander.version(version).usage("[options] <file_pattern ...>").option("-t, --template [file]", "use a custom .jst template", DEFAULTS.template).option("-c, --css [file]", "use a custom css file", DEFAULTS.css).option("-o, --output [path]", "use a custom output path (defaults to 'docs/')", DEFAULTS.output).parse(args).name = "docco";
    if (commander.args.length) {
      return exports.document(commander.args.slice(), commander);
    } else {
      return console.log(commander.helpInformation());
    }
  };

  exports.document = function(sources, options, callback) {
    var config, docco_styles, key, src, value, _i, _len;
    config = {};
    for (key in DEFAULTS) {
      value = DEFAULTS[key];
      config[key] = DEFAULTS[key];
    }
    if (key in DEFAULTS) {
      for (key in options) {
        value = options[key];
        config[key] = value;
      }
    }
    config.sources = [];
    for (_i = 0, _len = sources.length; _i < _len; _i++) {
      src = sources[_i];
      config.sources = config.sources.concat(exports.resolve_source(src));
    }
    config.docco_template = template(fs.readFileSync(config.template).toString());
    docco_styles = fs.readFileSync(config.css).toString();
    return ensure_directory(config.output, function() {
      var files, next_file;
      fs.writeFile(path.join(config.output, path.basename(config.css)), docco_styles);
      files = config.sources.slice();
      next_file = function() {
        if ((callback != null) && !files.length) callback();
        if (files.length) {
          return generate_documentation(files.shift(), config, next_file);
        }
      };
      return next_file();
    });
  };

}).call(this);
