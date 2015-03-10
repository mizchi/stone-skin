global.StoneSkin = require '../src/with-tv4'

describe 'StoneSkin', ->
  crudScenario = (Cls) ->
    class Item extends Cls
      storeName: 'Item'
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

  it 'should do crud by MemoryDb', ->
    crudScenario(StoneSkin.MemoryDb)

  it 'should do crud by IndexedDb', ->
    crudScenario(StoneSkin.IndexedDb)

  updateScenario = (Db) ->
    item = new Db
    item.ready
    .then -> item.clear()
    .then ->
      item.save {
        _id: 'xxx'
        title: 'test'
        body: 'init'
      }
    .then ->
      item.save {
        _id: 'xxx'
        title: 'test'
        body: 'updated'
      }
    .then -> item.all()
    .then (items) ->
      assert.ok items.length is 1
      assert.ok items[0].body is 'updated'
    .then ->
      item.save [
        {
          _id: 'xxx'
          title: 'test'
          body: 'zzz'
        }
        {
          _id: 'yyy'
          title: 'test'
          body: 'zzz'
        }
      ]
    .then -> item.all()
    .then (items) ->
      assert.ok items.length is 2

  it 'should update by same id (MemoryDb)', ->
    updateScenario(StoneSkin.MemoryDb)

  it 'should update by same id (IndexedDb)', ->
    updateScenario(StoneSkin.IndexedDb)

  validationScenario = (Db, done) ->
    class Item extends Db
      storeName: 'Item'
      schema:
        required: ['foo']
        properties:
          foo:
            type: 'string'
    item = new Item
    willSave =
      bar: 'string'
    item.ready
    .then -> item.clear()
    .then -> item.save willSave
    .then (saved) -> done('error')
    .catch (e) ->
      item.save [willSave]
      .then -> done('error')
      .catch (e) ->
        console.log 'catched', e
        done()

  it 'validate by IndexedDb', (done) ->
    validationScenario(StoneSkin.IndexedDb, done)

  it 'validate by MemoryDb', (done) ->
    validationScenario(StoneSkin.MemoryDb, done)
