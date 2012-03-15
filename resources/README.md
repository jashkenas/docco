#### Default Template

**docco** is the default Docco template and CSS file that outputs a ready-to-go
HTML page that you can upload and be done with.  It has an elegant page layout 
that is optimized for desktop viewing.  

You can use the default template simply by invoking Docco

    docco src/*.coffee

#### Pagelet Template

**pagelet** is a custom Docco template and CSS file that outputs a block of HTML
can be loaded and incorporated into an existing website structure (e.g. using 
jQuery.ajax calls for a specific doc page.)

You can use the pagelet template by passing the correct options to Docco.  If 
you are running from the docco directory

    docco src/*.coffee -t resources/pagelet.jst -c resources/pagelet.css

...will generate a custom output of a CSS file that contains only the syntax
highlighting styles, and HTML files describing the sources.

- Each page emits a `<ul class="sections">` element that contains all of the 
sections of generated HTML, for both the docs and highlighted code.
- If there is more than one source input, a `<ul class="file_list">` will be 
emitted, containing information about the source path and html page path for
each source.
