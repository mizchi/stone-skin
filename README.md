# StoneSkin

Isomorphic IndexedDb and in memory db wrapper.

Inspired by [mWater/minimongo](https://github.com/mWater/minimongo "mWater/minimongo").

Based on [mizchi/idb-wrapper-promisify](https://github.com/mizchi/idb-wrapper-promisify "mizchi/idb-wrapper-promisify")

## Feature

- Promise
- indexedDb or in memory db
- (optional) validation by jsonschema(tv4)

## Example

```coffee
StoneSkin = require('stone-skin/with-tv4')

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
```

## TODO

- Test

## LICENSE

MIT
