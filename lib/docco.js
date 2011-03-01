(function() {
  var css_path, deflang, destination, doc_dir, docco_styles, docco_template, ensure_directory, exec, fs, generate_documentation, generate_html, get_language, highlight, highlight_end, highlight_start, languages, opts, parse, parse_args, path, showdown, sources, spawn, template, template_path, _ref, _ref2;
  parse_args = function() {
    var arg, args, opts, sources;
    opts = {};
    sources = [];
    args = process.ARGV;
    while (arg = args.shift()) {
      if (/^--?/.test(arg)) {
        arg = arg.replace(/^--?/, '');
        opts[arg] = args.shift();
      } else {
        sources.push(arg);
      }
    }
    return [opts, sources.sort()];
  };
  generate_documentation = function(source, callback) {
    return fs.readFile(source, "utf-8", function(error, code) {
      var sections;
      if (error) {
        throw error;
      }
      sections = parse(source, code);
      return highlight(source, sections, function() {
        generate_html(source, sections);
        return callback();
      });
    });
  };
  parse = function(source, code) {
    var code_text, comment, docs_text, filter, has_code, language, line, lines, save, sections, should_ignore, _i, _len;
    save = function(docs, code) {
      return sections.push({
        docs_text: docs,
        code_text: code
      });
    };
    should_ignore = function(line) {
      var filter, _i, _len, _ref;
      _ref = language.ignore;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filter = _ref[_i];
        if (line.match(filter)) {
          return true;
        }
      }
    };
    filter = function() {
      var filter, _i, _len, _ref;
      _ref = language.filters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filter = _ref[_i];
        if (!filter.exec && !filter.test) {
          code = filter(code);
        } else {
          code = code.replace(filter, '');
        }
      }
      return code;
    };
    sections = [];
    language = get_language(source);
    has_code = docs_text = code_text = '';
    comment = language.comment_matcher;
    lines = (filter(code)).split('\n');
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      if (line.match(comment) && !should_ignore(line)) {
        if (has_code) {
          save(docs_text, code_text);
          has_code = docs_text = code_text = '';
        }
        docs_text += line.replace(comment, '') + '\n';
      } else {
        has_code = true;
        code_text += line + '\n';
      }
    }
    save(docs_text, code_text);
    return sections;
  };
  highlight = function(source, sections, callback) {
    var language, output, pygments, section, sections_code;
    language = get_language(source);
    pygments = spawn('pygmentize', ['-l', language.name, '-f', 'html', '-O', 'encoding=utf-8']);
    output = '';
    pygments.stderr.addListener('data', function(error) {
      if (error) {
        return console.error(error);
      }
    });
    pygments.stdout.addListener('data', function(result) {
      if (result) {
        return output += result;
      }
    });
    pygments.addListener('exit', function() {
      var fragments, i, section, _len;
      output = output.replace(highlight_start, '').replace(highlight_end, '');
      fragments = output.split(language.divider_html);
      for (i = 0, _len = sections.length; i < _len; i++) {
        section = sections[i];
        section.code_html = highlight_start + fragments[i] + highlight_end;
        section.docs_html = showdown.makeHtml(section.docs_text);
      }
      return callback();
    });
    sections_code = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = sections.length; _i < _len; _i++) {
        section = sections[_i];
        _results.push(section.code_text);
      }
      return _results;
    })();
    pygments.stdin.write(sections_code.join(language.divider_text));
    return pygments.stdin.end();
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
  fs = require('fs');
  path = require('path');
  showdown = require('./../vendor/showdown').Showdown;
  _ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;
  _ref2 = parse_args(), opts = _ref2[0], sources = _ref2[1];
  languages = {};
  deflang = function(ext, name, symbol, ignore, filters) {
    if (ignore == null) {
      ignore = [];
    }
    if (filters == null) {
      filters = [];
    }
    return languages[ext] = {
      name: name,
      symbol: symbol,
      comment_matcher: new RegExp('^\\s*' + symbol + '\\s?'),
      ignore: [new RegExp('(^#![/])')].concat(ignore),
      filters: [new RegExp('(^\\s*' + symbol + '{2,}\\s*$)', 'mg')].concat(filters),
      divider_text: '\n' + symbol + 'DIVIDER\n',
      divider_html: new RegExp('\\n*<span class="c1?">' + symbol + 'DIVIDER<\\/span>\\n*')
    };
  };
  deflang('.coffee', 'coffee-script', '#', [/(\#\{)/], [/^\s*\#{3}(?:(?:.|\s)(?!\#{3}))+(?:.|\s)\#{3}\s*/m]);
  deflang('.js', 'javascript', '//');
  deflang('.rb', 'ruby', '#', [/(\#\{)/]);
  deflang('.py', 'python', '#');
  get_language = function(source) {
    return languages[path.extname(source)];
  };
  doc_dir = opts['output'] || 'docs/';
  destination = function(filepath) {
    return doc_dir + path.basename(filepath, path.extname(filepath)) + '.html';
  };
  ensure_directory = function(callback) {
    return exec('mkdir -p #{doc_dir}', function() {
      return callback();
    });
  };
  template = function(str) {
    return new Function('obj', 'var p=[],print=function(){p.push.apply(p,arguments);};' + 'with(obj){p.push(\'' + str.replace(/[\r\t\n]/g, " ").replace(/'(?=[^<]*%>)/g, "\t").split("'").join("\\'").split("\t").join("'").replace(/<%=(.+?)%>/g, "',$1,'").split('<%').join("');").split('%>').join("p.push('") + "');}return p.join('');");
  };
  template_path = opts['template'] || (__dirname + '/../resources/docco.jst');
  docco_template = template(fs.readFileSync(template_path).toString());
  css_path = opts['css'] || (__dirname + '/../resources/docco.css');
  docco_styles = fs.readFileSync(css_path).toString();
  highlight_start = '<div class="highlight"><pre>';
  highlight_end = '</pre></div>';
  if (sources.length) {
    ensure_directory(function() {
      var next_file;
      fs.writeFile("" + doc_dir + "docco.css", docco_styles);
      next_file = function() {
        if (sources.length) {
          return generate_documentation(sources.shift(), next_file);
        }
      };
      return next_file();
    });
  }
}).call(this);
