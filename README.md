# StoneSkin

Isomorphic IndexedDb and in-memory db wrapper with jsonschema validation.

```
$ npm install stone-skin --save
```

Inspired by [mWater/minimongo](https://github.com/mWater/minimongo "mWater/minimongo"). And based on thin indexedDb wrapper [mizchi/idb-wrapper-promisify](https://github.com/mizchi/idb-wrapper-promisify "mizchi/idb-wrapper-promisify")

## Features

- ActiveRecord like API
- Isomorphic indexedDb or in-memory object
- Promisified
- Runnable in shared-worker and service-worker
- (optional) validation by jsonschema(tv4)

## Example

with babel(>=4.7.8) async/await (babel --experimental)

```js
global.Promise = require('bluebird');

import "babel/polyfill";
import StoneSkin from 'stone-skin/with-tv4';

class ItemStore extends StoneSkin.IndexedDb {
  storeName: 'Item';
  schema: {
    properties: {
      title: {
        type: 'string'
      }
    }
  }
}

let itemStore = new ItemStore();
(async () => {
  await itemStore.ready;
  await itemStore.save({title: 'foo', _id: 'xxx'});
  let item = await itemStore.find('xxx');
  console.log(item);
  let items = await itemStore.all();
  console.log(items);
})();
```

with coffee

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

with TypeScript

```js
///<reference path='stone-skin.d.ts' />
var StoneSkin = require('stone-skin/with-tv4');

interface ItemSchema = {
  _id: string;
  title: string;
};

class Item extends StoneSkin<ItemSchema> {
  // ...
}
```

See detail [stone-skin.d.ts](stone-skin.d.ts))

## Promisified Db API

`StoneSkin.IndexedDb` and `StoneSkin.MemoryDb` have same API

- `ready: Thenable<any>`: return resolved promise if indexedDb ready.
- `find(id: Id): Thenable<T>`: get first item by id
- `select(fn: (t: T) => boolean): Thenable<T[]>`: filtered items by function
- `first(fn: (t: T) => boolean): Thenable<T>`: get first item from filtered items
- `last(fn: (t: T) => boolean): Thenable<T>`: get last item from filtered items
- `all(): Thenable<T[]>`: return all items
- `clear(): Thenable<void>`: remove all items
- `save(t: T): Thenable<T>`: save item
- `save(ts: T[]): Thenable<T[]>`: save items
- `remove(id: Id): Thenable<void>`: remove item
- `remove(ids: Id[]): Thenable<void>`: remove items

## `StoneSkin.IndexedDb`

- `StoneSkin.IndexedDb<T>.prototype.toMemoryDb(): StoneSkin.MemoryDb`: return memory db by its items
- `StoneSkin.IndexedDb<T>.prototype.toSyncedMemoryDb(): StoneSkin.SyncedMemoryDb`: return synced memory db by its items.

## StoneSkin.SyncedMemoryDb

It has almost same API without Promise wrap.

## Migration helper

- `StoneSkin.utils.setupWithMigrate(currentVersion: number)`;

```coffee
StoneSkin.utils.setupWithMigrate 3,
  initialize: ->
    console.log 'init'        # fire at only first
  '1to2': ->
    console.log 'exec 1 to 2' # fire if last setup version is 1
  '2to3': ->
    console.log 'exec 2 to 3' # fire it if last setup version is 1 or 2
```

Need localStorage to save last version. It only works on browser.

## LICENSE

MIT
