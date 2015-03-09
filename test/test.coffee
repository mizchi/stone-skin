global.StoneSkin = require '../src/with-tv4'

describe 'StoneSkin', ->
  execScenario = (Cls) ->
    class Item extends Cls
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
      assert items.length is 0
    .then ->
      item.save {
        _id: 'xxx'
        title: 'test2'
        body: 'hello'
      }
    .then (saved) ->
      assert.ok !!saved.length is false
      item.save [
        {
          _id: 'yyy'
          title: 'test1'
          body: 'hello'
        }
      ]
    .then (saved) ->
      assert.ok saved.length is 1
      item.all()
    .then (items) ->
      assert items.length is 2
      item.remove 'xxx'
    .then ->
      item.all()
    .then (items) ->
      assert items.length is 1

  it 'should do crud by IndexedDb', ->
    execScenario(StoneSkin.IndexedDb)

  it 'should do crud by MemoryDb', ->
    execScenario(StoneSkin.MemoryDb)
