module Docco
  
  # The Docco::Parser isn't anything too fancy. We just identify lines that are
  # comments, and then continue until we reach the first line of code. The 
  # nature of that line determines the type of comment.
  class Parser
    
    COMMENT_LINE  = /^[ \t]*#/
    # CLASS_LINE    = /^[ \t]*class[ \t]+/
    # MODULE_LINE   = /^[ \t]*module[ \t]+/
    # METHOD_LINE   = /^[ \t]*def[ \t+]/
    # CONSTANT_LINE = /^[ \t]*[A-Z_0-9]+/
    
    attr_reader :code, :comments
    
    def initialize
      @code, @comments = [], []
    end
    
    # Returns an array of comments.
    def parse(lines)
      comment_lines = []
      comment_line_count = 0
      commenting = false
      lines.each_with_index do |line, i|
        is_comment = !! line.match(COMMENT_LINE)
        comment_lines << line if is_comment
        next if commenting && is_comment
        if is_comment
          commenting = i
        elsif commenting
          start = commenting - comment_line_count
          finish = i - 1 - comment_line_count
          comment_line_count += (finish - start + 1)
          @comments << Comment.new(lines[commenting...i], start , finish)
          commenting = false
        end
      end
      @code = lines - comment_lines
      self
    end
    
  end
  
end