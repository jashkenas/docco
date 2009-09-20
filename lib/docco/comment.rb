module Docco
  
  class Comment
    
    LINE_HEIGHT = 17
    PADDING     = 12
    
    HASH_MARK   = /\A[ \t]*#[ \t]*/
    
    
    attr_reader :text, :top
   
    def initialize(lines, start, finish)
      @lines, @start, @finish = lines, start, finish
      @top = LINE_HEIGHT * start - PADDING
    end
    
    def text
      @text ||= @lines.map {|l| l.sub(HASH_MARK, '') }.join(' ')
    end
    
  end
  
end