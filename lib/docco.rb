$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

autoload :ERB, 'erb'

module Docco
  
  autoload :CommandLine,  'docco/command_line'
  autoload :Comment,      'docco/comment'
  autoload :Parser,       'docco/parser'
  autoload :Printer,      'docco/printer'
  
  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
  
end