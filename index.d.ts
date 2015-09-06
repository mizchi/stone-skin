declare module StoneSkin {
  // type Id<T> = any;
  interface Id<T> {}
  // declare
  // Id:

  class Base<T> {
    validate(t: T): boolean;
  }

  class Async<T> extends Base<T> {
    ready: Promise<any>;
    find(id: Id<T>): Promise<T>;
    select(fn: (t: T) => boolean): Promise<T[]>;
    first(fn: (t: T) => boolean): Promise<T>;
    last(fn: (t: T) => boolean): Promise<T>;
    all(): Promise<T[]>;
    clear(): Promise<any>;
    save(t: T): Promise<T>;
    save(ts: T[]): Promise<T[]>;
    remove(id: Id<T>): Promise<any>;
    remove(ids: Id<T>[]): Promise<any>;
  }

  class Synced<T> extends Base<T> {
    find(id: Id<T>): T;
    select(fn: (t: T) => boolean): T[];
    first(fn: (t: T) => boolean): T;
    last(fn: (t: T) => boolean): T;
    all(): T[];
    clear(): void;
    save(t: T): T;
    save(ts: T[]): T[];
    remove(id: Id<T>): void;
    remove(ids: Id<T>[]): void;
  }

  export class IndexedDb<T> extends Async<T> {
    toMemoryDb(): MemoryDb<T>;
    toSyncedMemoryDb(): SyncedMemoryDb<T>;
  }

  export class LocalStorageDb<T> extends Async<T> {
    key: string;
  }

  export class FileDb<T> extends Async<T> {
    filename: string;
  }

  export class MemoryDb<T> extends Async<T> {}
  export class SyncedMemoryDb<T> extends Synced<T> {}
}
