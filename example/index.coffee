global.StoneSkin = require '../src/with-tv4'

window.addEventListener 'DOMContentLoaded', ->
  document.body.innerHTML = 'Hello'

  class Item extends StoneSkin.IndexedDb
    storeName: 'Item'
    schema:
      propeties:
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
