module Docco
  
  # This is the main command line for me.
  class CommandLine
  
    def initialize
      @input, @output = ARGV[0], ARGV[1]
      puts "Usage: docco /path/to/input.rb [output.html]" and exit unless @input
      @output ||= File.basename(@input, '.rb') + '.html'
    end
    
    def run
      lines = File.readlines(@input)
      parser = Parser.new.parse(lines)
      html = Printer.new.print(parser.code, parser.comments)
      File.open(@output, 'w') {|f| f.write(html) }
    end
    
  end
  
end