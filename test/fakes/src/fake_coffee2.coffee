#! /usr/bin/env coffee
# fizzbuzz.litcoffee
###
This is the fizzbuzz test in literate CoffeeScript.
###
## What should FizzBuzz do?
###
  The FizzBuzz test should print:

- 'fizz' for every number divisible by 3,
- 'buzz' for every number divisible by 5,
- 'fizzbuzz' if the number is divisible by 3 and 5
- else: just print the number.
###
## Fun Facts
###
  FizzBuzz is commonly used to interview programmers and test their coding skills.
    Once the author [@rmetzler](http://github.com/rmetzler) was asked on a job interview
to write a "coding test". He answered by asking if the meant test was FizzBuzz. The interviewer
said yes and made a statement to not test the interviewee. The author later learned he didn't
get the job, was sad and decided on writing FizzBuzz as a learning tool.
###
## FizzBuzz in CoffeeScript

# FizzBuzz in CoffeeScript could look like this:

fizzbuzz = (number) ->
  return 'fizzbuzz' if 0 == number % 15
  return 'buzz'     if 0 == number % 5
  return 'fizz'     if 0 == number % 3
  number.toString()

  for x in [1..100]

# pretty print
    console.log "#{x}\t->\t#{fizzbuzz x}"
