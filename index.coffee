Store = require 'idb-wrapper-promisify'
tv4 = require 'tv4'
uuid = require 'node-uuid'
clone = require 'clone'

class Repository
  name: null
  schema: {}
  constructor: ->
  save: -> throw new Error 'you should override'
  find: -> throw new Error 'you should override'
  findOne: -> throw new Error 'you should override'
  where: -> throw new Error 'you should override'
  clear: -> throw new Error 'you should override'

  # Internal
  _ensureId: (data) ->
    if data._id?
      data
    else
      cloned = clone(data)
      cloned._id = uuid()
      cloned

  validate: (data) -> tv4.validate data, @schema

class SyncedMemoryRepository extends Repository
  constructor: ->
    super
    @_data = []

  save: (data) ->
    if data instanceof Array
      if @schema and !!@skipValidate is false
        valid = data.every (data) => @validate(data)
        unless valid
          return new Error('validation error')
      objs = data.map (i) => @_ensureId(i)
      @_data.push objs...
    else
      @_data.push @_ensureId(data)
    return @_data

  find: (id) ->
    for item in @_data
      if item._id is id then return item
    undefined

  remove: (id) ->
    if id instanceof Array
      @_data = @_data.filter (i) -> i._id not in id
    else
      @_data = @_data.filter (i) -> i._id isnt id
    undefined

  findOne: (fn) ->
    for item in @_data
      if fn(item) then return item
    undefined

  where: (fn) ->
    result = []
    for i in @_data
      if fn(i) then result.push(i)
    return clone @_data.filter (i) -> fn(i)

  clear: -> @_data.length = 0
  all: -> clone(@_data)

class MemoryRepository extends SyncedMemoryRepository
  constructor: ->
    super
    @ready = Promise.resolve()

  save: -> Promise.resolve super
  remove: -> Promise.resolve super
  find: -> Promise.resolve super
  findOne: -> Promise.resolve super
  where: -> Promise.resolve super
  clear: -> Promise.resolve super
  all: -> Promise.resolve super

class IndexedDbRepository extends Repository
  keyPath: '_id'
  constructor: ->
    super
    @_store = new Store
      storeName: @storeName
      keyPath: @keyPath
    @ready = @_store.ready

  clear: -> @_store.clear()

  where: (fn) ->
    result = []
    @_store.iterate (i) ->
      if fn(i) then result.push(i)
    .then -> result

  # TODO: skip when cursor finds first item
  findOne: (fn) -> @where(fn).then (items) -> items[0]

  # Internal
  _saveBatch: (objs) ->
    if @schema and !!@skipValidate is false
      valid = objs.every (data) => @validate(data)
      unless valid
        return Promise.reject()
    @_store.putBatch(objs.map (i) => @_ensureId(i))

  save: (data) ->
    if data instanceof Array then return @_saveBatch(data)

    if @schema and !!@skipValidate is false
      unless @validate(data)
        return Promise.reject()
    @_store.put @_ensureId(data)

  remove: (id) ->
    if id instanceof Array
      @_store.removeBatch(id)
    else
      @_store.remove(id)

  find: (id) ->
    @_store.get(id)

  all: -> @_store.getAll()

  toMemoryDb: ->
    @_store.getAll()
    .then (items) =>
      memoryDb = new class extends MemoryRepository
        name: @name
        schema: @schema
      memoryDb._data = items
      memoryDb
  toSyncedMemoryDb: ->
    @_store.getAll()
    .then (items) =>
      memoryDb = new class extends SyncedMemoryRepository
        name: @name
        schema: @schema
      memoryDb._data = items
      memoryDb

window.addEventListener 'DOMContentLoaded', ->
  document.body.innerHTML = 'Hello'

  class ItemRepository extends IndexedDbRepository
  # class ItemRepository extends MemoryRepository
    storeName: 'Item'
    schema:
      # $ref: 'Item'
      propeties:
        # _id:
        #   type: 'string'
        title:
          type: 'string'
        body:
          type: 'string'

  item = new ItemRepository
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
