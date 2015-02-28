SS = require './index'
tv4 = require 'tv4'
SS.validate = (data, schema) ->
  validate: (data) -> tv4.validate data, schema, true

module.exports = SS
