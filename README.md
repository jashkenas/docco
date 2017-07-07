```
    ______
   /\  __ \
   \ \ \/\ \        ___         ___         ___         ___
    \ \ \ \ \      / __`\      /'___\      /'___\      / __`\
     \ \ \_\ \    /\ \ \ \    /\ \__/     /\ \__/     /\ \ \ \
      \ \____/    \ \____/    \ \____\    \ \____\    \ \____/
       \/___/      \/___/      \/____/     \/____/     \/___/

```
Docco is a quick-and-dirty, hundred-line-long, literate-programming-style
documentation generator. For more information, see:

http://jashkenas.github.com/docco/

### Installation:

  sudo npm install -g docco

### Usage: docco [options] [FILES]

  Options:

    -c, --css [file]       use a custom css file
    -e, --extension [ext]  use the given file extension for all inputs
    -f, --flatten          flatten the directory hierarchy
    -h, --help             output usage information
    -l, --layout [layout]  choose a built-in layouts (parallel, linear)
    -L, --languages [file] use a custom languages.json
    -m, --marked [file]    use custom marked options
    -o, --output [path]    use a custom output path
    -s, --setup [file],    use configuration file, normally docco.json
    -t, --template [file]  use a custom .jst template
    -V, --version          output the version number

### Configuring docco (.docco.json)

Docco a JSON configuration file for use so that command line specification of files is unnecessary.
The default file for this is .docco.json, but you can the command line parameter -s/--setup file to specify a different name.
This file should be in the working directory where the command is run.

```
{
  "sources": [
    "docco.litcoffee",
    "README.md"
  ]
  "layout": "linear"
}
```

Other values possible are:

```
      layout:     'parallel'
      output:     'doc'
      css:        'somefile.css'
      marked:     null
      setup:      '.docco.json'
      flatten:    true
```

### Build:

```
npm install
npm run clean
npm run build
```

### TODO:

    * Multiline comments
    * Links to files that are included or required
