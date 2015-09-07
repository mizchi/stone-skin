///<reference path='../index.d.ts' />
// run: tsc -t es6 example.ts; babel-node example.js
type Id<T> = StoneSkin.Id<T>;
declare var require: any;
declare var global: any;

global.StoneSkin = require('../with-tv4');

interface FooSchema {
  name: string;
}

class FooStore extends StoneSkin.MemoryDb<FooSchema> {
}

class BarStore extends StoneSkin.MemoryDb<{
  fooId: Id<FooStore>;
  name: string;
}> {
}

const foo = new FooStore();
const bar = new BarStore();
foo.save({name: "foo"})
.then(i => {
  console.log(i);
  return foo.find(i._id);
})
.then(foo => {
  return bar.save({
    fooId: foo._id,
    name: 'it\'s bar'
  })
})
.then(bar => {
  console.log(bar);
})
