package finitudeiterable;

import IterArmy;
import IterRange;
import IterRange.range as range;
import IterRange.rangeDown as rangeDown;
using Lambda;

/**
 * "Meet me halfway" iterator.
 * Inspired (not really) by the eponymous "Meat me in the middle" from `Black-Eyed-Peas`. lol
 *
 * Quick explanation
 * -----------------
 *
 * Trajectory of a first order IterMeet can be represented like this:
 *      
 *      *-------><-------* 
 *      
 *      Two inner hidden iterators start on each end (*) of an 
 *      array, iterate successively as next() is called on this object.
 *
 *      Eventually they will meet halfway, hence the name.
 *
 *
 * ```haxe
 * using IterMeet;
 * using Lambda;
 * ...
 * // first order is indicated in (1). 
 * for (x in [0,1,2,3,4].iterMeet(1)) 
 *      trace(x);  // 4,0,3,1,2
 * ``` 
 *
 * Generalization
 * --------------
 *
 * We can develop the concept a little bit more:
 *
 * ```
 * MeetIter Representation          Meeting-points  Inner-iterators     Departures
 * -------------------------------------------------------------------------------
 *
 * order 0  *--------------------->       0               1                 1
 * order 1  *---------><----------*       1               2                 2
 * order 2  *----><----*----><----*       2               4                 3
 * order 3   *-><-*-><-*-><-*-><-*        4               8                 5
 * order 4                                8               16                9
 * order n           . . .              2^(n-1)           2^n       n<=2 ? n : 2n-1
 *
 *
 * We can also *reverse everything* using a **negative order**:
 *
 * order -1 <----------*----------> Starting halfway, separating.
 * order -2 <-----*----><----*----> Dissecting in 2^n parts
 * order -3 <--*--><-*-><-*-><--*-> "
 * 
 * -------------------------------------------------------------------------------
 * ```  
 *
 * For instance for a third order IterMeet (8 inner iterators, 2^3):
 * ```for (x in [0,1,2,3,4,5,6,7,8,9].iterMeet(3)) trace(x);```
 *
 * IterMeet<T> is also an Iterable<T>
 * ----------------------------------
 *
 * This means `using Lambda`, we can do non-linear searches:
 *
 * ```haxe
 * using Lambda;
 * [ for (i in [0...1000]) i].iterMeet(5).find( is_a_good_number ) ];
 * ```
 *
 * the search will be performed non-linearly and will stop a.s.a.p. (i.e. as soon
 * as some good number was found, without having to traverse all the
 * array).
 * 
 * More
 * ----
 *
 * @sa See also `IterReverse` and `IterPart` in this library for alternative 
 * ways of iterating arrays.
 */
class IterMeet<T> {
    var a       : Array<T>;
    var orign   : Int;                      ///< Call-time n, see iterator()
    var n       : Int;                      ///< 2^n is the number of inner iterators
    var itArmy  : IterArmy<Int>;            ///< Int, the army iterates on indexes

    /** 
     * @param (Array<T>) Array to iterate, using this IterMeet
     * @param (Int n) Binary log of the number of inner iterators.
     *                There will be 1<<n inner iterators produced. (1<<n is 2^n).
     *                n=0 will act as a regular iterator.
     *                n<0 will reverse the iterators order , see 
     *                class doc.
     *
     *                Eg:
     *
     *                      n | 2^n
     *                   -----------
     *                      0 | 1
     *                      1 | 2
     *                      2 | 4
     *                      3 | 8
     *                      4 | 16
     *                      5 | 32
     *                      6 | 64
     *                      n | 2^n
     *
     *                This will work alright even if (1<<n) >= ar.length,
     *                but in that case n will be recalculated to get the
     *                closest to array length (e.g. if length is 14,
     *                and n is 5, n will be set to 3 because 2^3 is the 
     *                closest... 2^4 = 16 would be more than 12).
     *                
     **/
    public function new(ar:Array<T>, someN:Int) {
        orign = someN;
        var isReversedOrder = someN < 0;

        a = ar;
        n = cast Math.abs(someN);
        if (n == 0) {
            itArmy = new IterArmy<Int>([ range(0, a.length) ]);
            return;
        }

        if ((1<<n) > ar.length) {
            var log2n = 0; var t = ar.length; while ((t >>= 1) > 0) log2n++;
            n = log2n; 
        } 

        var table = precalcKeyFromSeq(1<<n);
        var soldiers = new List<Iterator<Int>>();

        for (i in 0...1 << n) {
            var whichRange = table[i];
            var nbValuesinRange = 
                    (1 << n) > a.length
                        ? (whichRange < a.length ? 1 : 0)
                        :  whichRange < a.length % (1 << n)
                            ? Math.ceil (a.length / (1 << n))
                            : Math.floor(a.length / (1 << n))
            ;
            if (nbValuesinRange <= 0) break;
            var isBackwardRange = i % 2 == (isReversedOrder ? 0 : 1);
            var ab = whichRange < a.length % (1 << n)
                        ? whichRange * Math.ceil(a.length / (1 << n))
                        : a.length % (1 << n)
                            * Math.ceil(a.length / (1 << n))
                            + (whichRange - (a.length % (1 << n)))
                            * Math.floor(a.length / (1 << n))
            ;
            var ad = ab + nbValuesinRange;
            // trace('iterator $i whichRange:$whichRange nbValuesinRange:$nbValuesinRange isBackwardRange:$isBackwardRange     ab:$ab ad:$ad ');
            soldiers.add(isBackwardRange 
                ? rangeDown(ad - 1, ab - 1) 
                : range(ab, ad)
            );
        }

        itArmy = new IterArmy<Int>(soldiers);
    }

    public static function iterMeet<T>(ar:Array<T>, someN:Int):IterableIterator<T>
        return new IterMeet(ar, someN);

    public function hasNext()  return itArmy.hasNext();
    public function next()     return a[itArmy.next()];
    public function iterator():IterableIterator<T> return new IterMeet(a, orign);



    // predictability
    // for good predictability/consistency (determinism), here's the strategy
    // to allocate inner iterators:
    // 1-------------------------------------------------------2 n=1
    // 1--------------------------34---------------------------2 n=2     
    // 1-----------56-------------34--------------78-----------2 n=3     
    // 1----9a-----56------bc-----34------de------78-----fg----2 n=4     
    // 1-hi-9a--jk-56--lm--bc--no-34--pq--de--rs--78--tu-fg-vw-2 n=5     

    // To get this right and (somewhat) easy, we can think of those iterators
    // as a binary tree of ranges
    //
    //                                           BEUARGGG.. CRAB PEOPLE...!
    //                                           /
    //                                          /
    //                                 O     O
    //                                  range
    //                                 /     \
    //                            range0      range1
    //                            /   \         /   \
    //                        rng0.0 rng0.1 1.0      1.1
    //                       /  \     / \   /  \    \   \
    //                    0.0.0 001 010 011 100 101 110 111    <- keys
    //                     / ---/   /   /\    \  \   \---. \--------------------  
    //     ---------------- /  -----   /  \    \  ------. \------------.        \_
    //    /    /    .----.--  /   /   /    \   /-----.   \----.       / \       / \
    // 0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111
    //  (0)  (8)  (9)  (4)  (5)  (10) (11) (2)  (3)  (12) (13) (6)  (7) (14)  (15) (1)
    //
    // 
    //       Any range with a key finishing by .2 iterates backwards
    //
    //  Our homecooked method 
    //  involves some binary<->decimal sauce, 
    //  here is an example w/ 16 inner iter:
    //
    //  -----------------------------
    //  |seq. | key  |key(seq) =    | 
    //  |-----+------+--------------|
    //  |  0  | 0000 |       full0  | 
    //  |  1  | 1111 |       full1  | backwards
    //  |  2  | 0111 | 0   + full1  | 
    //  |  3  | 1000 | 1   + full0  |  "
    //  |  4  | 0011 | 00  + full1  |  
    //  |  5  | 0100 | 01  + full0  |  "
    //  |  6  | 1011 | 10  + full1  | 
    //  |  7  | 1100 | 11  + full0  |  "
    //  |  8  | 0001 | 000 + full1  |  
    //  |  9  | 0010 | 001 + full0  |  "
    //  | 10  | 0101 | 010 + full1  |  
    //  | 11  | 0110 | 011 + full0  |  "
    //  | 12  | 1001 | 100 + full1  | 
    //  | 13  | 1010 | 101 + full0  |  "
    //  | 14  | 1101 | 110 + full1  | 
    //  | 15  | 1110 | 111 + full0  |  "
    //  ------+----------------------
    public static function precalcKeyFromSeq(numberOfInnerIterators:Int):Array<Int> {
        var n = numberOfInnerIterators;
        var table = []; 
        var log2n = 0; var t = n; while ((t >>= 1) > 0) log2n++;
        var full0 = 0;
        var full1 = n - 1;

        table.push(full0);
        if (n > 1) table.push(full1);

        for (i in 1...log2n) {
            for (ii in 0...1<<i) {
                table.push(
                    ii % 2 == 0
                    ? (ii << log2n - i) | ((1 << log2n - i) - 1)   // full 1
                    : (ii << log2n - i)                            // full 0
                );
            }
        }
        return table;
    }
}


