// import "babel/polyfill";
import StoneSkin from '../with-tv4';

class ItemStore extends StoneSkin.FileDb {
  get filepath() { return process.cwd() + '/item.json';}
}

let itemStore = new ItemStore();
itemStore.ready.then(() => {
  return itemStore.save({a: 1});
})
.then(item => {
  console.log("saved", item);
  return itemStore.all();
})
.then(items => {
  console.log(items);
})
.catch(e =>{
  console.log(e);
});
