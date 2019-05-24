package finitudeiterable;

import FinitudeIterable;
using Lambda;
using IterReverse;
using IterChain;
using IterLoop;

/**
 * Cyclic (infinite) iterator over an Iterable<T>
 * or make that iterator loop N times before finishing.
 *
 * ```
 * using IterLoop;
 * for (n in [1,2,3].iterLoop(2)) trace(n);     // 1,2,3,1,2,3
 * ```
 *
 * You can turn it into an infinite loop using no argument: 
 *
 * for (n in [1,2,3].loop()) ...                // infinite cycle of [1,2,3]
 *
 * loop(0) will never loop.
 * loop(n) when n < 0 is undocumented and will throw an exception.
 * (it would have be nice for loop(-1) to iterate backwards, but we do not 
 *  know how to iterate backwards for all iterables).
 *
 * PingPong
 * --------
 * There is also a function iterPingPong(), which parameter has the 
 * same semantics as above and works like so:
 *
 * [1,2,3].iterPingPong(2).array()  // [1,2,3,3,2,1,1,2,3,3,2,1]
 * 
 */
class IterLoop<T> implements FinitudeIterable {
    var a   : Iterable<T>;          ///< Iterable to loop
    var n   : Int;                  ///< Number of loops, 1<<30 for infinite
    var m   : Int;                  ///< Math.abs(n)
    var d   : Int;                  ///< Number of completed loops (d for done)
    var it  : Iterator<T>;          ///< Tmp it of a or b. Reobtained when nec.
    var ii  : Bool;                 ///< Is infinite
    var hn  : Bool;                 ///< Has next 

    /**
     * INFINITY is defined so that NINFINITY == -INFINITY 
     * (we couldn't do it with e.g. 1<<31).
     */
    public static inline var INFINITY:  Int =  1<<30;
    public static inline var NINFINITY: Int = -1<<30;

    /**
     * @param (Int n)       0: resolves to an IterVoid.
     *                      1: same as directly iterating itb
     *                      n>=0: loop n times
     *                      n<0:  loop n times, backwards
     *                      IterLoop.INFINITY:  infinite loop
     *                      IterLoop.NINFINITY: infinite loop, backwards
     */
    public function new(itb:Iterable<T>, loops:Int=1<<30) {
        if (loops < 0 
            && Std.is(a, FinitudeIterable)
            && cast (a, FinitudeIterable).isInfiniteIter() 
        ) throw "Cannot iterate backwards on infinite iter";
        a = itb;
        n = loops; 
        m = n < 0 ? (n == INFINITY ? INFINITY : -n) : n;
        it = cast (n < 0 ? a.iterReverse() : a.iterator());
        d = 0;
        ii = m == INFINITY || (Std.is(a, FinitudeIterable)
                                && cast (a, FinitudeIterable).isInfiniteIter());
        hn = __hasNext();   // so the looping can kick in before iterator end
                            // it won't work w/ some composite iterators otherwise
    }

    // this weird-looking set up is for Mr. Bean 
    // to handle composite iterators (e.g. IterArmy).
    // didn't manage to optimize it having  `cd test ; ./x all` all running well.
    public function hasNext() return hn;
    public function __hasNext():Bool {
        if (n == 0) return false;
        if (!it.hasNext()) {
            if (n != INFINITY && ++d >= m) return false;
            it = n < 0 ? a.iterReverse() : a.iterator();
            return it.hasNext();
        }
        return true; 
    }

    public inline function next() {
        var ret = it.next();
        hn = __hasNext();   // so the looping can kick in before iterator end
                            // it won't work w/ some composite iterators otherwise
        return ret;
    }

    public inline function isInfiniteIter() return ii;
    public inline function iterator():IterableIterator<T> return new IterLoop(a, n); 
    
    public inline static function iterLoop<T>(itb:Iterable<T>, loops:Int=1<<30):IterableIterator<T> 
        return new IterLoop<T>(itb, loops);

    public inline static function loop<T>(itb:Iterable<T>, loops:Int=1<<30):IterableIterator<T>
        return new IterLoop<T>(itb, loops);

    /**
     * Regular iterator over itr; once it's finished, partial IterLoop
     * over the n last elements, x times. Infinite loop when x is 1<<30
     * See IterLoopLastN.
     **/
    public inline static function loopLastN<T>(itr:Iterable<T>, n:Int, x:Int=1<<30):IterableIterator<T>
        return new IterLoopLastN(itr, n, x);

    /** 
     * Ping-pong loops: loops that go forwards then backwards: 1 time.
     * It can be repeated n times, infinitely when n is IterLoop.INFINITY.
     *
     *          zero times (n=0)
     * *------. 
     *        . 
     * <------. once (n=1)
     * .
     * *------.
     *        .
     * <------. twice (n=2)
     *
     * @throw Exception when Iterable<T> isInfiniteIter()
     **/
    public static inline function iterPingPong<T>(a:Iterable<T>, n:Int=1<<30):IterableIterator<T> {
        // this variant does not precipitate, 
        // and will throw whenever isInfiniteIter():
        return new IterChain( n >= 0 
            ? [a, a.iterReverse()]
            : [a.iterReverse(), a]
        ).iterLoop(cast Math.abs(n));
    }

    public static inline function pingpong<T>(a:Iterable<T>, n:Int=1<<30):IterableIterator<T> return iterPingPong(a, n);
}
