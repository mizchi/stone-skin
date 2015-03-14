global.Promise = require('bluebird');

import "babel/polyfill";
import StoneSkin from '../with-tv4';

class ItemStore extends StoneSkin.MemoryDb {
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
