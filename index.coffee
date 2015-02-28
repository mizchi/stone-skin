Store = require 'idb-wrapper-promisify'
window.addEventListener 'DOMContentLoaded', ->
  document.body.innerHTML = 'Hello'
  store = new Store
    storeName: 'test'
    keyPath: 'id'
  store.ready
  .then -> store.clear()
  .then ->
    console.log 'db ready'

  # put and get
    store.put({id: 1, name: 'bar'})
  .then ->
    store.get(1)
  .then (data) ->
    console.log 'result:', data

  # putBatch and getAll
    store.putBatch [
      {id: 2, name: 'baz'}
      {id: 3, name: 'quz'}
    ]
  .then ->
    console.log 'put done'
    store.getAll()
  .then (data) ->
    console.log data

  # iterate
    store.iterate (item) ->
      console.log item
  .then ->
    console.log 'iterate done'
