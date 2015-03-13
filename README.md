# StoneSkin

Isomorphic IndexedDb and in memory db wrapper.

```
$ npm install stone-skin
```

Inspired by [mWater/minimongo](https://github.com/mWater/minimongo "mWater/minimongo").

Based on [mizchi/idb-wrapper-promisify](https://github.com/mizchi/idb-wrapper-promisify "mizchi/idb-wrapper-promisify")

## Features

- Promise
- indexedDb or in memory db
- (optional) validation by jsonschema(tv4)

## Example

```coffee
StoneSkin = require('stone-skin/with-tv4')

class Item extends StoneSkin.IndexedDb
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
```

## Migration helper

```coffee
StoneSkin.utils.setupWithMigrate '3',
  initialize: ->
    console.log 'init'        # at first
  '1to2': ->
    console.log 'exec 1 to 2' # call it if last setup version is 1
  '2to3': ->
    console.log 'exec 2 to 3' # call it if last setup version is 1 or 2
```

Need localStorage to save last version.

## TODO

- DogFooding

## LICENSE

MIT
