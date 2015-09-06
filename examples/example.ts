///<reference path='../index.d.ts' />
// run: tsc -t es6 example.ts; babel-node example.js
type Id<T> = StoneSkin.Id<T>;
declare var require: any;
declare var global: any;

global.StoneSkin = require('../with-tv4');

interface ItemSchema {
  _id?: Id<ItemSchema>;
  name: string;
}

class ItemStore extends StoneSkin.MemoryDb<ItemSchema> {
}

const item = new ItemStore();
item.save({name: "foo"})
.then(i => {
  console.log(i);
  item.find(<Id<ItemSchema>>(i._id));
})
