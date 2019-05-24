package finitudeiterable;

import IterArmy;
import IterRange;
using Lambda;

/**
 * Inter-partitions sequential iterator: IterPart. 
 * Array<T> is divided into ``n`` partitions. 
 * On each iteration, the next value of one of those partition is returned,
 * in a sequential way. 
 *
 * This is a representation of a second-order IterPart:
 *
 *    *--------->*---------->   
 *    0 subiter1 10 subiter2 20
 *
 * @example
 * using IterPart;
 * import IterRange.range as range;
 * ...
 * for (x in [ for (i in 0...21) i ].iterPart(2))
 *      trace(x);
 * @endexample
 *
 * It will yield 0,10,1,11,2,12,13,3,14,4,15,5,16,6,17,7,18,8,19,9,20.
 *
 * Order n and negative orders
 * ---------------------------
 *
 * ```
 *    IterPart Representation               Inner-iterators  
 *    ------------------------------------------------------
 *    order 1  *--------------------->       1          
 *    order 2  *--------->*---------->       2          
 *    order 3  *---->*-------->*----->       3          
 *    order 4  *--->*---->*---->*---->       4          
 *    etc.
 *
 *    A negative order reverts this:
 *
 *    Order -1 <---------------------*
 *    Order -2 <----------*<---------*
 *    Order -3 <------*<------*<-----*
 *    etc.
 *
 *    Order 0 is equivalent to IterVoid.
 * ```  
 *
 * @example 
 * // negative 3rd order IterPart: 
 * for (x in [0,1,2,3,4,5,6,7,8,9].iterPartition(-3)) 
 *      trace(x);
 * @endexample 
 *
 * Note
 * ----
 *
 * If n >= array.length, 1 will be used instead. This is because it would 
 * have the same result, and also because it simplifies things internally.
 *
 * IterMeet<T> is also an Iterable<T>. This means `using Lambda` we can do non-linear searches:
 * [ for (i in [0...1000]) i].iterMeet(5).find( is_a_good_number ) ];
 *
 * The search will be performed non-linearly, and will stop ASAP.
 * 
 * More
 * ----
 *
 * If you like this, check out the nice ```Loosy/FP.hx``` (functional 
 * programming library of methods) by Sledorze. It's a nice and powerful extension
 * to Lambda and makes a nice companion to this library of Iterators.
 *
 * @sa See also `IterReverse` and `IterMeet` in this library for alternative 
 * ways of iterating arrays.
 */
class IterPart<T> {
    var a       : Array<T>;
    var orign   : Int;               ///< So it's recalled w/ iterator()
    var n       : Int;
    var itArmy  : IterArmy<Int>;     ///< Int bc the army iterates on indexes

    /** 
     * @param (Array<T>) Array to iterate using a IterPart
     * @param (Int n) Number of partitions. 
     *                This will be set to 1 if n >= ar.length (it would return
     *                the same result).
     *                n<0 will have subiterator run backwards.
     *                n=0 will not iterate.
     **/
    public function new(ar:Array<T>, parts:Int) {
        orign = parts;
        a = ar;
        var isReversed = parts < 0;
        n = cast Math.abs(parts);
        if (n >= ar.length) n = 1;
        if (n == 0) {
            // order 0 is no iterator.
            itArmy = new IterArmy<Int>([]);
        }
        else {
            var departures = new IterRange<Float>(0, a.length, a.length / n).array();

            // ----------------------------------------------------
            var i = 0;
            var soldiers = new List<IterRange<Int>>();
            var ab:Int = cast Math.floor(departures[0]);

            while (++i < n) { // n-1 bc we want to set last soldier manually
                var ad:Int = cast Math.floor(departures[i]);
                soldiers.add(new IterRange<Int>(ab, ad, 1, isReversed));
                ab = ad;
            }
            soldiers.add(new IterRange<Int>(ab, a.length, 1, isReversed));
            itArmy = new IterArmy<Int>(soldiers);
            // ---------------------------
        }
    }

    public inline static function iterPart<T>(ar:Array<T>, parts:Int) : IterableIterator<T>
        return new IterPart(ar, parts);

    public inline function hasNext()  return itArmy.hasNext();
    public inline function next()     return a[itArmy.next()];

    public inline function iterator():IterableIterator<T> return new IterPart(a, orign);
}
