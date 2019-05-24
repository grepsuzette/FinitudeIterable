package finitudeiterable;

import FinitudeIterable; 

/**
 * Potentially infinite iterator that iterate normally until the end then returns 
 * the last n values (n=1 by default), either indefinitely or for a given number of 
 * times. 
 *
 * The name comes from the fact it sounds better than IterEndLoop or IterRepeatNLast,
 * think of it as a sustained note in musical theory. Also, when n is 2, it can be
 * thought of as a trilled note.
 *
 * Also, we have defined some convenient aliases which play with parameters a bit:
 *
 * import IterRange.range as range;
 * using IterSustain;
 *
 * // Infinite
 * ["fish", "monkey", "human"].sustain(); // fish,monkey,human,human,human, ...
 * ["fish", "monkey", "human"].trill();   // fish,monkey,human,monkey,human, ...
 * range(0,5).loopLastN(3);               // 0,1,2,3,4,2,3,4,2,3,4,2,3,4,2,3,4. ...
 *
 * // Finite
 * ["fish", "monkey", "human"].sustain(1);// fish,monkey,human,human
 * ["fish", "monkey", "human"].trill(1);  // fish,monkey,human,monkey,human
 * range(0,5).loopLastN(3,2);             // 0,1,2,3,4,2,3,4,2,3,4
 *
 * @note An inlined alias of loopLastN() also appears in IterLoop. They can 
 * interchangeably used without increasing the compiled size of the program.
 */

enum IterSustainTrill {
    Sustain;
    Trill;
}

class IterSustain<T> implements FinitudeIterable {
    var a       : Iterable<T>;
    var it      : Iterator<T>;
    var t       : T;                    ///< Last value read.
    var u       : T;                    ///< Before-last value read.
    var x       : Int;                  ///< xtra times. 1<<30 means infinite
    var i       : Int;                  ///< Repeats done after normal phase
    var j       : Int;                  ///< When x==2, j++ (check even/odd)
    var n       : Int;                  ///< Either 1 (Sustain) or 2 (Trill)

    /**
     * Ctor.
     * @param (times)  How many extra times the last n value(s) will be returned.
     *                 A value <= 0 does not make sense and will throw 
     *                 an exception.
     *                 By default, is 1<<30, which is infinite (and will not
     *                 get decreased)
     * @param (IterSustainTrill _n) An enum made to restrict the n to 1 (Sustain)
     *                              or 2 (Trill). Default (null) resolves to 
     *                              1 (Sustain).
     */
    public function new(itr:Iterable<T>, xtratimes:Int=1<<30, n_:IterSustainTrill=null) { 
        a = itr; 
        it = a.iterator(); 
        x = xtratimes; 
        if (x <= 0) throw "invalid times: " + xtratimes;
        i = 1;
        j = 0;
        n = switch (n_) {
            case Trill: 2;
            case _: 1;
        }
    }

    /** The n parameter is always 1 for a sustain. */
    public inline static function sustain<T>(itr:Iterable<T>, xtratimes:Int=1<<30) : IterableIterator<T>
        return new IterSustain(itr, xtratimes, Sustain);

    /** The n parameter is always 2 for a trill. */
    public inline static function trill<T>(itr:Iterable<T>, xtratimes:Int=1<<30): IterableIterator<T>
        return new IterSustain(itr, xtratimes, Trill);

    /**
     * /!\ The parameter order for the last 2 arguments is swapped for this function. 
     * @note There is also an inlined alias of this function in IterLoop. 
     **/
    // public inline static function loopLastN<T>(itr:Iterable<T>, n:Int, xtratimes:Int=1<<30)
    //     return new IterSustain(itr, xtratimes, n);

    public inline function isInfiniteIter() return x == 1<<30;
    public inline function iterator():IterableIterator<T> return new IterSustain(a, x);
    public inline function hasNext() return i <= x || it.hasNext();
    public function next() return it.hasNext() 
        ? { u = t; t = it.next(); } 
        : n == 1
            ? { if (x != 1<<30) i++; t; }
            : { j++ % 2 == 0 
                    ? u
                    : { if (x != 1<<30) i++ ; t; }
              }
    ;
}
