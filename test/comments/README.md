## Docco Comment Parser Test Data

This directory contains test data files to verify that single-line 
and block comments work as expected.  Each source file contains code
and comments in the language it is testing, with a special format that
can be read by the tests that use them.  

### Identifying the number of expected comments per-file.  

For each file, comments are read out, trimmed of white-space and newlines,
and then output as a comma separated list of entries.  

The first comment in each file has a special format, and describes the
number of expected comments, of each type, that the file should output
when having docco run over it, when run with and without the --blocks flag.

A Descriptor example (javascript), which is always a single-line comment.
     
     // Single:1 - Block:2
     

### Results as a custom CSV template

The file `comments.jst` in this directory is used when running docco over
the example source files, and it breaks the doc blocks into a CSV list
of doc texts.  This CSV list is loaded by the comments parser test, and
used to validate the expected output.
