# Single:3 - Block:2
world = "World!"

console.log "Hello #{world}"  

### 
This file will report 3 comments when parsed without
block comments enabled, because the single line comment
parser will match the '#' at the beginning and end of the 
block comment.

As a result, all of this text will be considered code. It's 
not a good situation, but that's how `docco` works.
### 
  

console.log "// Comment"

console.log "### Comment ###"
