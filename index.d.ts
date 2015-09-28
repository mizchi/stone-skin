declare module StoneSkin {
  interface Id<T> {}

  class Base<T> {
    validate(t: T): boolean;
  }

  interface __WithId<T> {
    _id: Id<T>;
  }

  class Async<T> extends Base<T> {
    ready: Promise<any>;
    find(id: Id<Async<T>>)   : Promise<(T & __WithId<T>)>;
    find(ids: Id<Async<T>>[]): Promise<(T & __WithId<T>)[]>;
    fetch(id: Id<Async<T>>): Promise<T & __WithId<T>>;
    select(fn: (t: T) => boolean): Promise<(T & __WithId<T>)[]>;
    first(fn: (t: T) => boolean): Promise<T & __WithId<T>>;
    last(fn: (t: T) => boolean): Promise<T & __WithId<T>>;
    all(): Promise<(T & __WithId<T>)[]>;
    clear(): Promise<any>;
    save(t: T): Promise<T & __WithId<T>>;
    save(ts: T[]): Promise<(T & __WithId<T>)[]>;
    remove(id: Id<Async<T>>): Promise<any>;
    remove(ids: Id<Async<T>>[]): Promise<any>;
  }

  class ImmutableLoader<T> extends Base<T> {
    find(id: Id<T>): T & __WithId<T>;
    fetch(id: Id<T>): T & __WithId<T>;
    select(fn: (t: T) => boolean): T & __WithId<T>[];
    all(): (T & __WithId<T>)[];
  }

  class Synced<T> extends Base<T> {
    find(id: Id<Synced<T>>): T & __WithId<T>;
    find(ids: Id<Synced<T>>[]): (T & __WithId<T>)[];
    fetch(id: Id<Synced<T>>): T & __WithId<T>;
    select(fn: (t: T) => boolean): T & __WithId<T>[];
    first(fn: (t: T) => boolean): T & __WithId<T>;
    last(fn: (t: T) => boolean): T & __WithId<T>;
    all(): (T & __WithId<T>)[];
    clear(): void;
    save(t: T): T & __WithId<T>;
    save(ts: T[]): (T & __WithId<T>)[];
    remove(id: Id<Synced<T>>): void;
    remove(ids: Id<Synced<T>>[]): void;
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
