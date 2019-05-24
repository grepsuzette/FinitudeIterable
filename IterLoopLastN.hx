package finitudeiterable;

import FinitudeIterable; 
using IterLoop;

/**
 * Regular iterator over an iterable; once it finished, partial IterLoop
 * over the n last elements will occur, x times. Infinite loop when x is 1<<30.
 *
 * When
 * ----
 *    | n is 0, it just traverses the parameter Iterable's iterator (identity).
 *    | n is 1, IterSustain is an optimized version.
 *    | n is 2, IterTrill is an optimized version.
 *    |
 *    | **x** is IterLoopLastN.INFINITY the loop is infinite.
 *    | **x** is IterLoopLastN.NINFINITY the loop is infinite and goes backwards.
 *
 * Some examples
 * -------------
 *
 * import IterRange.range as range;
 * using IterSustain;
 *
 * // Infinite
 *
 * ["fish", "monkey", "human"].sustain(); // fish,monkey,human,human,human, ...
 * ["fish", "monkey", "human"].trill();   // fish,monkey,human,monkey,human, ...
 * range(0,5).loopLastN(3);               // 0,1,2,3,4,2,3,4,2,3,4,2,3,4,2,3,4. ...
 *
 * // Finite
 *
 * ["fish", "monkey", "human"].sustain(1);// fish,monkey,human,human
 * ["fish", "monkey", "human"].trill(1);  // fish,monkey,human,monkey,human
 * range(0,5).loopLastN(3,2);             // 0,1,2,3,4,2,3,4,2,3,4
 *
 * @note An inlined alias of loopLastN() also appears in IterLoop. They can 
 * interchangeably used without increasing the compiled size of the program.
 */

class IterLoopLastN<T> implements FinitudeIterable {
    var a       : Iterable<T>;
    var it      : Iterator<T>;          ///< Iterator over a
    var l       : Array<T>;             ///< LIFO last x read
    var it2     : Iterator<T>;          ///< l.loop()
    var x       : Int;                  ///< xtra times. 1<<30 means infinite
    var n       : Int;                  ///< n as in repeat the last n elements of a
    var ii      : Bool;                 ///< is infinity

    public static inline var INFINITY:Int  = IterLoop.INFINITY;
    public static inline var NINFINITY:Int = IterLoop.NINFINITY;

    /**
     * Ctor.
     * @param (times)  How many extra times the last n value(s) will be returned.
     *                 A value <= 0 does not make sense and will throw 
     *                 an exception.
     *                 By default, is 1<<30, which is infinite (and will not
     *                 get decreased)
     *
     * @param (Int _n) The n as in repeat the last n elements of the iterable
     *                 xtratimes times.
     *                 For n=1 see IterSustain.
     *                 For n=2 see IterTrill.
     */
    public function new(itr:Iterable<T>, n_:Int, xtratimes:Int=1<<30) { 
        a = itr; 
        it = a.iterator(); 
        x = xtratimes; 
        n = n_;
        l = [];
        ii  =  x == INFINITY 
            || x == NINFINITY
            || Std.is(a, FinitudeIterable) 
                && cast (a, FinitudeIterable).isInfiniteIter();
    }

    /**
     * @note There is also an inlined alias of this function in IterLoop. 
     **/
    public inline static function loopLastN<T>(itr:Iterable<T>, n:Int, x:Int=1<<30):IterableIterator<T>
        return new IterLoopLastN(itr, n, x);

    public function isInfiniteIter() return ii;
    public inline function iterator():IterableIterator<T> return new IterLoopLastN(a, n, x);

    public function hasNext() { 
        if (!it.hasNext() && it2 == null) it2 = l.loop(x);  // only when 'it' fin.
        return x == INFINITY
            || x == NINFINITY
            || it.hasNext() 
            || it2.hasNext()
        ;
    }

    public function next() return it.hasNext() 
        ? { var v = it.next(); l.push(v); if (l.length > n) l.shift(); v; } 
        : it2.next()
    ; 
}

