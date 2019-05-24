package finitudeiterable;

import FinitudeIterable;
using IterLoop;
using Lambda;

/**
 * IterArmy: an Iterator of Iterators, alternating between each inner iterator.
 *
 * @example
   using Lambda;
   using IterArmy;
   ...
   public function test_reading_from_2_arrays_simple() {
       // we want to read from 2 arrays
       // alternating values of squares and cubes:

       var squares = [ for (i in 0...10) i*i ];
       var cubes = [ for (i in 0...10) i*i*i ];

       for (x in new IterArmy<Int>([ 
           squares.iterator(), 
           cubes.iterator() 
       ]))
           trace(x);       // we'll get 0,0,1,1,4,16,9,27 etc, alternating
                           // squares and cubes.
   }
 * @endexample
 * You can also have several soldier iterators running along the _same_
 * Iterable. For example see IterPart and IterMeet, they both
 * use an IterArmy.
 */
class IterArmy<T> implements FinitudeIterable {
    var army       : Iterable<Iterator<T>>;
    var captain    : IterLoop<Iterator<T>>;
    var nxtSoldier : Iterator<T>;
    var nArmy      : Int;                            ///< Army count
    var isInfinite : Bool;

    public function new(a:Iterable<Iterator<T>>) {
        army = a;
        captain = cast army.iterLoop();                 // cyclic,infinite
        nArmy = army.count();

        // Since hasNext() must not change the state of 
        // the iterator, we must initialize it here
        nxtSoldier = getNextSoldierHavingNext_orNull();
        
        isInfinite = army.exists(function(it) 
            return Std.is(it, FinitudeIterable) 
                && cast (it, FinitudeIterable).isInfiniteIter()
        );
    }

    public function hasNext() return nxtSoldier != null; 

    public function next() {
        var ret = nxtSoldier.next();
        nxtSoldier = getNextSoldierHavingNext_orNull();
        return ret;
    }

    public function isInfiniteIter() return isInfinite;

    private function getNextSoldierHavingNext_orNull() {
        var soldier = null;
        // went full circle && none => we're done
        var n = 0;
        while (n++ <= nArmy - 1 && ((soldier = captain.next()) != null)) {
            // It would have been nice to allow removal of finished soldiers,
            // unfortunately it's not really possible 2016 Sun Feb 21 14:23:30 CST 2016
            if (soldier.hasNext()) return soldier;
        }
        // if we arrive here, IterArmy has finished iterating 
        return null;
	}
    

    /** So IterArmy is an Iterable, and can be used w/ Lambda & cie. */
    public function iterator():IterableIterator<T> return new IterArmy(army);
}
