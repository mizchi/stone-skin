# StoneSkin

Isomorphic IndexedDb and in-memory db wrapper with jsonschema validation.

```
$ npm install stone-skin --save
```

Inspired by [mWater/minimongo](https://github.com/mWater/minimongo "mWater/minimongo"). And based on thin indexedDb wrapper [mizchi/idb-wrapper-promisify](https://github.com/mizchi/idb-wrapper-promisify "mizchi/idb-wrapper-promisify")

## Features

- ActiveRecord like API
- Universal indexedDb or in-memory object
- Promisified
- Runnable in shared-worker and service-worker
- (optional) validation by jsonschema(tv4)
- Selectable target
  - IndexedDb(browser)
  - LocalStorageDb(browser)
  - FileDb(node)
  - MemoryDb(universal)

FileDb and LocalStorageDb do just only serialization to json/string. Don't use them with big data.

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

- `ready: Promise<any>`: return resolved promise if indexedDb ready.
- `find(id: Id): Promise<T>`: get first item by id
- `select(fn: (t: T) => boolean): Promise<T[]>`: filtered items by function
- `first(fn: (t: T) => boolean): Promise<T>`: get first item from filtered items
- `last(fn: (t: T) => boolean): Promise<T>`: get last item from filtered items
- `all(): Promise<T[]>`: return all items
- `clear(): Promise<void>`: remove all items
- `save(t: T): Promise<T>`: save item
- `save(ts: T[]): Promise<T[]>`: save items
- `remove(id: Id): Promise<void>`: remove item
- `remove(ids: Id[]): Promise<void>`: remove items

## `StoneSkin.IndexedDb`

- `storeName: string;` You need to set this value when you extend it.
- `StoneSkin.IndexedDb<T>.prototype.toMemoryDb(): StoneSkin.MemoryDb`: return memory db by its items
- `StoneSkin.IndexedDb<T>.prototype.toSyncedMemoryDb(): StoneSkin.SyncedMemoryDb`: return synced memory db by its items.

## `StoneSkin.FileDb`

- `filepath: string;` You need to set this value when you extend it.

## `StoneSkin.LocalStorageDb`

- `key: string;` You need to set this value when you extend it.

## `StoneSkin.SyncedMemoryDb`

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
