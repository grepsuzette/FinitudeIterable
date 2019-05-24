package finitudeiterable;

/**
 * Iterables that may be infinite must implement an isInfiniteIter() function to specify
 * whether they are infinite in their current implementation. This information
 * is only used by some complex iterators such as IterMulti.
 *
 * Regular simple iterables that can only be finite don't need to implement 
 * this function. However, composite iterators which finitude relies on subiterators
 * should.
 */
interface FinitudeIterable {
    function isInfiniteIter() : Bool;
}

