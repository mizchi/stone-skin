global.StoneSkin = require '../src/with-tv4'
global.Promise = require 'bluebird'

# window.addEventListener 'DOMContentLoaded', ->
#   document.body.innerHTML = 'Hello'

do ->
  # class Item extends StoneSkin.IndexedDb
  class Item extends StoneSkin.MemoryDb
    storeName: 'Item'
    schema:
      properties:
        title:
          type: 'string'
        body:
          type: 'string'

  item = new Item
  item.ready
  .then ->
    item.clear()
  .then ->
    item.all()
  .then (items) ->
    console.log items
  .then ->
    item.save {
      _id: 'xxx'
      title: 'test2'
      body: 'hello'
    }
  .then ->
    item.save [
      {
        _id: 'yyy'
        title: 'test1'
        body: 'hello'
      }
    ]
  .then ->
    item.all()
  .then (items) ->
    console.log items
    item.remove 'xxx'
  .then ->
    item.all()
  .then (items) ->
    console.log items
