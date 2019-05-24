package finitudeiterable;

/**
 * An iterator that never hasNext().
 */
class IterVoid<T> {
    public function new() {}
    public function hasNext() return false;
    public function next() return null;
    public function iterator():IterableIterator<T> return this;
}
