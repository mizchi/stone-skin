Store = require 'idb-wrapper-promisify'
uuid = require 'node-uuid'
clone = require 'clone'

module.exports = SS = StoneSkin = {}

SS.validate = (data, schema) ->
  validate: (data) -> tv4.validate data, schema, true

class SS.Base
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

  validate: (data) -> SS.validate?(data, @schema) ? do ->
    console.warn 'No validater. Please set StoneSkin.validate or require stone-skin/with-tv4'
    true

class SS.SyncedMemoryDb extends SS.Base
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

class SS.MemoryDb extends SS.SyncedMemoryDb
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

class SS.IndexedDb extends SS.Base
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
    result = objs.map (i) => @_ensureId(i)
    @_store.putBatch(result).then -> result

  save: (data) ->
    if data instanceof Array then return @_saveBatch(data)

    if @schema and !!@skipValidate is false
      unless @validate(data)
        return Promise.reject()
    result = @_ensureId(data)
    @_store.put(result)
    .then -> result

  remove: (id) ->
    if id instanceof Array
      @_store.removeBatch(id)
    else
      @_store.remove(id)

  find: (id) ->
    @_store.get(id)
    .catch (e) -> undefined

  all: -> @_store.getAll()

  toMemoryDb: ->
    @_store.getAll()
    .then (items) =>
      memoryDb = new class extends SS.MemoryDb
        name: @name
        schema: @schema
      memoryDb._data = items
      memoryDb

  toSyncedMemoryDb: ->
    @_store.getAll()
    .then (items) =>
      memoryDb = new class extends SyncedMemoryDb
        name: @name
        schema: @schema
      memoryDb._data = items
      memoryDb
