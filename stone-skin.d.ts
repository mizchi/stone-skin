declare module StoneSkin {
  type Id = string;
  export interface Thenable<R> {
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => Thenable<U>): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => U): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => void): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => Thenable<U>): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => U): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => void): Thenable<U>;
    catch(error: any): Thenable<any>;
  }

  class Base<T> {
    validate(t: T): boolean;
  }

  class Async<T> extends Base<T> {
    ready: Thenable<any>;
    find(id: Id): Thenable<T>;
    select(fn: (t: T) => boolean): Thenable<T[]>;
    first(fn: (t: T) => boolean): Thenable<T>;
    last(fn: (t: T) => boolean): Thenable<T>;
    all(): Thenable<T[]>;
    clear(): Thenable<any>;
    save(t: T): Thenable<T>;
    save(ts: T[]): Thenable<T[]>;
    remove(id: Id): Thenable<any>;
    remove(ids: Id[]): Thenable<any>;
  }

  class Synced<T> extends Base<T> {
    find(id: Id): T;
    select(fn: (t: T) => boolean): T[];
    first(fn: (t: T) => boolean): T;
    last(fn: (t: T) => boolean): T;
    all(): T[];
    clear(): void;
    save(t: T): T;
    save(ts: T[]): T[];
    remove(id: Id): void;
    remove(ids: Id[]): void;
  }

  export class IndexedDb<T> extends Async<T> {
    toMemoryDb(): MemoryDb<T>;
    toSyncedMemoryDb(): SyncedMemoryDb<T>;
  }

  export class MemoryDb<T> extends Async<T> {}
  export class SyncedMemoryDb<T> extends Synced<T> {}
}
