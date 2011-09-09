(function() {
  var arg, args, css_file, destination, docco_styles, docco_template, ensure_directory, exec, ext, fs, generate_documentation, generate_html, get_language, highlight, highlight_end, highlight_start, inline_css, l, languages, parse, path, showdown, sources, spawn, structured_output, template, template_file, version, _ref;
  version = '0.3.1';
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
      if (error) {
        return console.error(error.toString());
      }
    });
    pygments.stdin.addListener('error', function(error) {
      console.error("Could not use Pygments to highlight the source.");
      return process.exit(1);
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
  generate_html = function(source, sections) {
    var dest, html, relative_destination, title;
    title = path.basename(source);
    dest = destination(source);
    relative_destination = structured_output ? function(source) {
      return (path.dirname(dest) + '/').replace(/[^\/]*\//g, '../') + destination(source);
    } : function(source) {
      return path.basename(destination(source));
    };
    html = docco_template({
      title: title,
      styles: inline_css ? docco_styles : '',
      sections: sections,
      sources: structured_output ? sources : sources.map(function(source) {
        return path.basename(source);
      }),
      relative_destination: relative_destination
    });
    console.log("docco: " + source + " -> " + dest);
    return ensure_directory(path.dirname(dest), function() {
      return fs.writeFile(dest, html);
    });
  };
  fs = require('fs');
  path = require('path');
  showdown = require('./../vendor/showdown').Showdown;
  _ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;
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
    return 'docs/' + (structured_output ? path.dirname(filepath) + '/' : '') + path.basename(filepath, path.extname(filepath)) + '.html';
  };
  ensure_directory = function(dir, callback) {
    return exec("mkdir -p " + dir, function() {
      return callback();
    });
  };
  template = function(str) {
    return new Function('obj', 'var p=[],print=function(){p.push.apply(p,arguments);};' + 'with(obj){p.push(\'' + str.replace(/[\r\t\n]/g, " ").replace(/'(?=[^<]*%>)/g, "\t").split("'").join("\\'").split("\t").join("'").replace(/<%=(.+?)%>/g, "',$1,'").split('<%').join("');").split('%>').join("p.push('") + "');}return p.join('');");
  };
  sources = [];
  args = process.ARGV.slice();
  while (args.length) {
    switch (arg = args.shift()) {
      case '--version':
        console.log('Docco v' + version);
        return;
      case '--structured-output':
        inline_css = structured_output = true;
        break;
      case '--inline-css':
        inline_css = true;
        break;
      case '--css':
      case '-c':
        if (args.length) {
          css_file = args.shift();
        }
        break;
      case '--template':
      case '-t':
        if (args.length) {
          template_file = args.shift();
        }
        break;
      default:
        sources.push(path.normalize(arg));
    }
  }
  sources.sort();
  if (template_file != null) {
    docco_template = template(fs.readFileSync(template_file).toString());
  }
  if (!(docco_template != null)) {
    docco_template = template(fs.readFileSync(__dirname + '/../resources/docco.jst').toString());
  }
  if (css_file != null) {
    docco_styles = fs.readFileSync(css_file).toString();
  }
  if (!(docco_styles != null)) {
    docco_styles = fs.readFileSync(__dirname + '/../resources/docco.css').toString();
  }
  highlight_start = '<div class="highlight"><pre>';
  highlight_end = '</pre></div>';
  if (sources.length) {
    ensure_directory('docs', function() {
      var files, next_file;
      if (!inline_css) {
        fs.writeFile('docs/docco.css', docco_styles);
      }
      files = sources.slice();
      next_file = function() {
        if (files.length) {
          return generate_documentation(files.shift(), next_file);
        }
      };
      return next_file();
    });
  }
}).call(this);
