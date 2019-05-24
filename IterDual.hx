package finitudeiterable;

import FinitudeIterable;

/**
 * A special case of an IterMulti. It has 2 subiterators that are iterated together
 * on each iteration, and can be accessed with _1 and _2. (which you can typedef
 * to a pair).
 *
 * By default, iteration stops as soon as one of the subiterators have finished 
 * iterating, though this can be changed (see below).
 *
 * Quick instantiation using dual with iterables (Array etc):
 * ----------------------------------------------------------
 * 
 * ```haxe
 * import IterDual.dual as dual;
 *
 * public function test() {
 *     for (i in dual([1,2,3], [1,2,3]))   // Or new IterDual(.....)
 *         assertTrue(i._1 == i._2);
 * }
 * ```
 *
 *  When the iterables do not have the same count()
 *  ===============================================
 *
 *  What happens when the two iterable parameters do not have the same count?
 *  Let's first declare those 2 iterables of different sizes to demonstrate the 3 
 *  different options:
 *
 *  var trinidad    = ["pater", "fili", "spiritus"];
 *  var fruits      = ["banana", "coconut"];
 *
 *  Cut
 *  ---
 *  We can cut the iteration short as soon as one of the iterators finishes,
 *  (that is the default):
 *                                          // v------ optional
 *  for (i in new IterDual( trinidad, fruits, Cut ))
 *      trace(i._1 + " receives a " + i._2 );
 *
 *          // "pater receives a banana"
 *          // "fili receives a coconut"
 *
 *  Null
 *  ----
 *  Or the shorter iterator can return null after it has finished iterating:
 *
 *  for (i in new IterDual( trinidad, fruits, Null ))
 *      trace(i._1 + " receives a " + i._2 );
 *
 *          // "pater receives a banana"
 *          // "fili receives a coconut"
 *          // "spiritus receives a null"
 *
 *  Loop
 *  ----
 *  Finally, the shorter iterator can be detected automatically and be 
 *  turned into a loop:
 *
 *  for (i in new IterDual( trinidad, fruits, Loop ))
 *      trace(i._1 + " receives a " + i._2 );
 *
 *          // "pater receives a banana"
 *          // "fili receives a coconut"
 *          // "spiritus receives a banana"
 *
 *
 * IterDual is an iterable<T,U>
 * ----------------------------
 *
 * It may not be immediately apparent why. This allows us to zip values from
 *  2 iterables of different types respecting the order and without almost any 
 *  code to write: 
 *  
 *  ```
 *  using Lambda;
 *
 *  var names = [ "biscuit", "hat", "hammer", "tv set" ];
 *  var adjectives = [ "dubious", "insane", "gorgeous" ];
 *
 *  trace( dual(names, adjectives).list() );     // this associates them
 * 
 *  dual(names, adjectives).map( function(i) return 'A ${i._2} ${i._1}' ).iter( trace );
 *      // "A dubious biscuit"
 *      // "A insane hat"
 *      // "A gorgeous hammer"
 *  ```
 *
 */
enum IterDualShortcoming { 
    Cut;    ///< Cut iteration short as soon as one iterable is finished
    Null;   ///< Iterable coming short will return null 
    Loop;   ///< Loop over the shorter iterable until the other one finishes
}

class IterDual<T,U> implements FinitudeIterable {
    var _a          :   Iterable<T>;
    var _b          :   Iterable<U>;
    var _it         :   Iterator<T>;
    var _it2        :   Iterator<U>;
    var _loop       :   IterDualShortcoming;
    var _whichFin   :   Int;  ///< Which one finished? 0: none, _1 or _2.
    var _isInfinite :   Bool;

    public function new(
            zit:Iterable<T>, 
            zit2:Iterable<U>, 
            zloop:IterDualShortcoming=null
    ) {
        _a = zit;
        _b = zit2;
        _it = _a.iterator();
        _it2 = _b.iterator();
        _loop = zloop == null ? Cut : zloop;
        _whichFin = 0;
        _isInfinite = _prepareIsInfiniteIter();
    }

    public inline static function dual<T,U>(
            zit:Iterable<T>, 
            zit2:Iterable<U>,
            zloop:IterDualShortcoming=null
    ):IterDual<T,U>
        return new IterDual(zit, zit2, zloop);

    /**
     * eg:
     * import IterDual.dualLoop as dualLoop;
     * dualLoop([1,2,3], ["a", "b", "c", "d", "e", "f"]).array()[3];
     *   // ^- [3] is { _1: 1, _2: "d" }
     */
    public inline static function dualLoop<T,U>(
            zit:Iterable<T>, 
            zit2:Iterable<U>
    ):IterDual<T,U>
        return new IterDual(zit, zit2, Loop);

    /**
     * eg:
     * import IterDual.dualCut as dualCut
     * using Lambda;
     * dualCut([1,2,3], ["a", "b", "c", "d", "e", "f"]).count();
     *   // ^- count() is 3
     */
    public inline static function dualCut<T,U>(
            zit:Iterable<T>, 
            zit2:Iterable<U>
    ):IterDual<T,U>
        return new IterDual(zit, zit2, Cut);
    
    /**
     * eg:
     * import IterDual.dualNull as dualNull
     * using Lambda;
     * dualNull([1,2,3], ["a", "b", "c", "d", "e", "f"]).array()[3]._2;
     *   // ^- second field of fourth element is null
     */
    public inline static function dualNull<T,U>(
            zit:Iterable<T>, 
            zit2:Iterable<U>
    ):IterDual<T,U>
        return new IterDual(zit, zit2, Null);

    public function next() return { _1: _it.next(), _2: _it2.next() };
    public function hasNext() { 
        var t =  _it.hasNext();
        var u = _it2.hasNext();
        switch (_loop) {
            case Null: return t || u;
            case Cut:  return t && u;
            case Loop:
               if ( t &&  u) return true;
               if (!t && !u) return false;
               // just one of them is finished
               if (_whichFin == 0) {
                   if (!t) { _whichFin = 1;  _it = _a.iterator(); }
                   else    { _whichFin = 2; _it2 = _b.iterator(); } 
               }
               else if (_whichFin == 1 && !u
                    || (_whichFin == 2 && !t)) return false;
               else {
                   if (_whichFin == 1 && !t) {  _it = _a.iterator(); return true; }
                   if (_whichFin == 2 && !u) { _it2 = _b.iterator(); return true; }
               }
               return true;
        }
    }
    public function iterator() return new IterDual(_a, _b, _loop);
    public function isInfiniteIter() return _isInfinite;
    private function _prepareIsInfiniteIter() {
        if (Std.is(_a, FinitudeIterable) && cast (_a, FinitudeIterable).isInfiniteIter()) return true;
        if (Std.is(_b, FinitudeIterable) && cast (_b, FinitudeIterable).isInfiniteIter()) return true;
        return false;
    }
}
