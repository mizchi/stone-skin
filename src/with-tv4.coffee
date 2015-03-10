StoneSkin = require './index'
tv4 = require 'tv4'
StoneSkin.validate = (data, schema) ->
  tv4.validate data, (schema ? {}), true

StoneSkin.createValidateReason = (data, schema) ->
  tv4.validateResult data, (schema ? {}), true

module.exports = StoneSkin
