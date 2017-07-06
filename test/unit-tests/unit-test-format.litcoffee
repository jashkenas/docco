# This tests if parse is working correctly.

  { assert, should } = require('chai'); should()
  format = require '../../src/format'

  describe 'docco format', () ->

    it 'format docco', () ->
