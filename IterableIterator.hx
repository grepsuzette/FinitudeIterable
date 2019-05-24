package finitudeiterable;

/**
 * A mere typedef to specify objects that are both iterator and iterable
 */
typedef IterableIterator<T> = {
    > Iterator<T>,
    > Iterable<T>,
}
