Store = require 'idb-wrapper-promisify'
uuid = require 'node-uuid'
clone = require 'clone'

r = if require? then require else null

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
      # console.log("on save", data)
      return @_pushOrUpdate(data)
      # console.log("on save", ret, data)

  # raw find
  _find: (id) ->
    for item in @_data
      if item._id is id then return item
    undefined

  # will wrap
  find: (id) -> @_find(id)

  remove: (id) ->
    if id instanceof Array
      @_data = @_data.filter (i) -> i._id not in id
    else
      @_data = @_data.filter (i) -> i._id isnt id
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
    return clone @_data.filter (i) -> fn(i)

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

class StoneSkin.CommitableDb extends StoneSkin.MemoryDb
  commit: => throw 'Override me'
  # will cause validation error
  save: -> Promise.resolve(super).then @commit
  remove: -> Promise.resolve super.then @commit
  clear: -> Promise.resolve(super).then @commit

class StoneSkin.FileDb extends StoneSkin.CommitableDb
  filepath: null
  constructor: ->
    super
    unless @filepath?
      throw new Error "You have to set filepath in FileDb"

    fs = r 'fs'
    if fs.existsSync @filepath
      @_data = JSON.parse fs.readFileSync(@filepath)
    else
      @_data = []

  commit: (ret) =>
    new Promise (done) =>
      unless @filepath?
        throw new Error "_data is not serializable."
      try
        jsonstr = JSON.stringify(@_data)
      catch e
        throw new Error ""

      fs = r 'fs'
      fs.writeFile(@filepath, jsonstr, -> done(ret))

class StoneSkin.LocalStorageDb extends StoneSkin.CommitableDb
  key: null
  constructor: ->
    super
    unless @key?
      throw new Error "You have to set key in LocalStorageDb"
    unless localStorage?
      throw new Error "This envinronment can't touch localStorage"

    if localStorage[@key]?
      @_data = JSON.parse localStorage.getItem(@key)
    else
      @_data = []

  commit: (ret) =>
    new Promise (done) =>
      unless @key?
        throw new Error "You have to set key in LocalStorageDb"
      try
        jsonstr = JSON.stringify(@_data)
      catch e
        throw new Error "_data is not serializable."
      localStorage.setItem(@key, jsonstr)
      done(ret)


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
    if data instanceof Array
      return Promise.resolve([]) if data.length is 0
      return @_saveBatch(data)

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
      return Promise.resolve() if id.length is 0
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

class Migrator
  # type version: string;

  # version: version; // current version
  constructor: (@version, @opts = {}) ->
    @lastVersion = @getLastVersion()
    @needInitialize = !@lastVersion

  # version?
  getLastVersion: ->
    localStorage?.getItem('ss-dbVersion')

  # boolean
  needUpdated: ->
    if @lastVersion? and @lastVersion is @version
      false
    else
      true

  # () => void
  _setDbVersionToLocalStorage: ->
    localStorage?.setItem 'ss-dbVersion', @version

  # () => Promise<void>
  migrate: ->
    Promise.resolve(
      if @needInitialize
        @_setDbVersionToLocalStorage()
        @opts.initialize?()
      else
        null
    )
    .then =>
      if @needUpdated()
        @_migrateByVersion @lastVersion, @version
        .then =>
          @_setDbVersionToLocalStorage()

  # (from: version, to: version) => Promise<void>
  _migrateByVersion: (from, to) =>
    from = parseInt from, 10
    to   = parseInt to, 10
    start = Promise.resolve()
    while from < to
      fnName = "#{from}to#{from + 1}"
      fn = @opts[fnName]
      start = start.then fn
      from++
    start

## utils
StoneSkin.utils = {}

# () => Promise<void>
StoneSkin.utils.setupWithMigrate = (currentVersion, opts = {}) ->
  migrator = new Migrator currentVersion, opts
  migrator.migrate()
