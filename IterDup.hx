package finitudeiterable;

/**
 * IterDup, an iterator that duplicates entries of an iterable n times.
 *
 * @example
 * using IterDup;
 * trace( [0,1,2].dup(2) );
 * 
 * // Or:
 * for (i in new IterDup([0,1,2], 2)) trace(i); // 0, 0, 1, 1, 2, 2
 * @endexample
 *
 * .dup(0) is eq to an IterVoid()
 * .dup(1) is eq to not using dup()
 * .dup(2) is eq to dup(), duplicating each entry
 * .dup(n) produces each entry n times.
 * 
 * Negative n are forbidden at this time and throw exception.
 */
class IterDup<T> {
    var a               : Iterable<T>;          ///< Iter to dup
    var n               : Int;                  ///< n
    var it              : Iterator<T>;          ///< a's iter
    var c               : Int;                  ///< dups done
    var t               : T;

    /** @throw if count < 0 (reserved) */
    public function new( itr:Iterable<T>, count:Int=2 ) {
        a = itr;
        n = count;
        if (n < 0) throw "fkwr2 reserved";
        c = 0;
        it = a.iterator();
        if (it.hasNext()) t = it.next();
    }

    public inline static function dup<T>( itr:Iterable<T>, count:Int=2 ) : IterableIterator<T>
        return new IterDup(itr, count);

    public inline function hasNext() return n > 0 && (c < n || it.hasNext());
    public function next() {
        if (c++ < n) return t;
        c = 1;
        return t = it.next();
    }

    public function iterator():IterableIterator<T> return new IterDup<T>(a, n);
}
