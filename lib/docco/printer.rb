module Docco
  
  class Printer
    
    TEMPLATE = File.read(ROOT + '/templates/template.html.erb')
    
    # Print takes in an array of lines of code and an array of Docco::Comments.
    def print(code, comments)
      @code, @comments = code, comments
      @styles = File.read(ROOT + '/static/styles.css')
      ERB.new(TEMPLATE).result(binding)
    end
    
  end
  
end