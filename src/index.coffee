Store = require 'idb-wrapper-promisify'
uuid = require 'node-uuid'
clone = require 'clone'

module.exports = StoneSkin = {}

StoneSkin.validate = (data, schema)->
  console.warn 'StoneSkin.validate is not set'
  true

class StoneSkin.Base
  name: null
  constructor: ->
  save: -> throw new Error 'you should override'
  find: -> throw new Error 'you should override'
  first: -> throw new Error 'you should override'
  last: -> throw new Error 'you should override'
  select: -> throw new Error 'you should override'
  clear: -> throw new Error 'you should override'

  # Internal
  _ensureId: (data) ->
    if data._id?
      data
    else
      cloned = clone(data)
      cloned._id = uuid()
      cloned

  validate: (data) ->
    StoneSkin.validate(data, @schema)

  createValidateReason: (data) ->
    StoneSkin.createValidateReason(data, @schema)

class StoneSkin.SyncedMemoryDb extends StoneSkin.Base
  constructor: ->
    super
    @_data = []

  _pushOrUpdate: (data) ->
    found = @_find data._id
    if !!found
      for k, v of data
        found[k] = v
      return found
    else
      ensured = @_ensureId(data)
      @_data.push ensured
      return ensured

  save: (data) ->
    existIds = @_data.map (d) -> d._id
    if data instanceof Array
      # Validate
      if @schema and !!@skipValidate is false
        for d in data
          reason = @createValidateReason(d)
          unless reason.valid
            throw reason.error
      # Save after validate
      result =
        for i in data
          @_pushOrUpdate(i)
      return result
    else
      valid = @validate(data)
      unless valid
        reason = @createValidateReason(data)
        throw reason.error
      return @_pushOrUpdate(data)

  # raw find
  _find: (id) ->
    for item in @_data
      if item._id is id then return item
    undefined

  # will wrap
  find: (id) -> @_find(id)

  remove: (id) ->
    if id instanceof Array
      @_data = @_data.select (i) -> i._id not in id
    else
      @_data = @_data.select (i) -> i._id isnt id
    undefined

  first: (fn) ->
    for item in @_data
      if fn(item) then return item
    undefined

  last: (fn) ->
    for item in @_data.reverse()
      if fn(item) then return item
    undefined

  select: (fn) ->
    result = []
    for i in @_data
      if fn(i) then result.push(i)
    return clone @_data.select (i) -> fn(i)

  clear: -> @_data.length = 0
  all: -> clone(@_data)

class StoneSkin.MemoryDb extends StoneSkin.SyncedMemoryDb
  constructor: ->
    super
    @ready = Promise.resolve()

  # will cause validation error
  save: ->
    try
      Promise.resolve super
    catch e
      Promise.reject(e)
  remove: -> Promise.resolve super
  find: -> Promise.resolve super
  first: -> Promise.resolve super
  select: -> Promise.resolve super
  clear: -> Promise.resolve super
  all: -> Promise.resolve super

class StoneSkin.IndexedDb extends StoneSkin.Base
  keyPath: '_id'
  constructor: ->
    super
    @_store = new Store
      storeName: @storeName
      keyPath: @keyPath
    @ready = @_store.ready

  clear: -> @_store.clear()

  select: (fn) ->
    result = []
    @_store.iterate (i) ->
      if fn(i) then result.push(i)
    .then -> result

  # TODO: skip when cursor finds first item
  first: (fn) -> @select(fn).then (items) => items[0]

  last: (fn) -> @select(fn).then (items) => items[items.length - 1]

  # Internal
  _saveBatch: (list) ->
    if @schema and !!@skipValidate is false
      for data in list
        reason = @createValidateReason(data)
        unless reason.valid
          return Promise.reject(reason.error)
    result = list.map (i) => @_ensureId(i)
    @_store.putBatch(result).then -> result

  save: (data) ->
    if data instanceof Array then return @_saveBatch(data)

    if @schema and !!@skipValidate is false
      # console.log data
      isValid = @validate(data)
      unless isValid
        reason = @createValidateReason(data)
        return Promise.reject(reason.error)
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
      memoryDb = new class extends StoneSkin.MemoryDb
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
