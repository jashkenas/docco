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

[![Build Status](https://travis-ci.org/robblovell/docco.svg?branch=master)](https://travis-ci.org/robblovell/docco)

```
npm install
npm run clean
npm run build
```

### Release Notes:

#### Functionality:

    * Added configuration file capabilities with a .docco.json file
    * --setup flag to specify a different configuration file
    * Images (.png, .jpg, .jpeg and .tiff) can now be copied to the doccumentation directory
    * The source directory structure is kept in the target location by default
    * --flatten flag to override keeping the directory structure and flattening it
    * For markdown files, referenced images are displayed in the code section
      which means that in the parallel theme, images are displayed on the right
    * Multiline comments
    * Allow images to be removed from the link menu for templates 
    * New layout: sidebyside

#### Refactors:

    * Code refactored into smaller chuncks
    * Unit testing framework added and unit tests written to %85 coverage (more work needed here)
    * 'npm build' builds all javascript with gulp
    * 'npm test' runs all unit tests
    * travis ci build and badge

#### Breaking Changes:

    * .jst template files need to remove call to 'path.basename()'
      to modify the destination source file for links to other files

      This:

        `<a class="source" href="<%= path.basename(destination(source)) %>">`

      Needs to be changed to

        `<a class="source" href="<%= destination(source) %>">`

    * hierarchical directory structure of source is kept by default.
      Use --flatten to get the old behavior


### TODO:

    * Links to files that are included or required
    * publish to github
    * index.html documentation update
    * All built javascript is ignored in .gitignore (npm packaging is the problem here).

