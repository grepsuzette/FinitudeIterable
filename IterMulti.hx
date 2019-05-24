package finitudeiterable;

using Lambda;
import FinitudeIterable;

/**
 * IterMulti, an iterator that iterates multiple subiterators in parallel on each 
 * iteration. 
 *
 * ------------------------------------------------------------------------------
 * /!\ Warning: Wed Mar 16 17:37:37 CST 2016
 *  This iterator has a lot of overhead (5 times the overhead of IterDual).
 *  Do not use it for anything speed-critical. 
 *  I would suggest using the IterDual instead, or even better, 
 *  the one in tink_lang by Back2dos. Anyway if you really need raw speed
 *  (critical loops where operation cost is little) you don't want to use high 
 *  level stuffs normally.
 * ------------------------------------------------------------------------------
 *
 * By default, iteration stops as soon as one of the subiterators have finished 
 * iterating. However more complex schemes are available (see below).
 *
 * A simple example
 * ================
 * 
 * ```haxe
 * import IterMulti.multi as multi;
 *
 * public function test() {
 *     for (i in multi([[1,2,3], [4,5,6], [7,8,9]])) {  // Or new IterMulti(.....)
 *          trace(i[0]);  // 1 then 2, then 3
 *          trace(i[1]);  // 4 then 5, then 6
 *          trace(i[2]);  // 7 then 8, then 9
 *      }
 * }
 * ```
 *
 * IterMulti is an iterable<Dynamic>
 * =================================
 *
 * For instance using Lambda, this allows to regroup values as simple 
 * as by adding .array() or .list():
 *  
 *  ```
 *  using Lambda;
 *  import IterMulti.multi as multi;
 *  var names      = [ "biscuit"        , "hat"    , "hammer"   ];
 *  var adjectives = [ "dubious"        , "insane" , "gorgeous" ];
 *  var but        = [ "but delicious"                          ];
 *
 *  var a = multi([names, adjectives, but], Loop).array();  // this associates them:
 *
 *  Now a[0] = ['biscuit' , 'dubious'  , 'but delicious']
 *      a[1] = ['hat'     , 'insane'   , 'but delicious']
 *      a[2] = ['hammer'  , 'gorgeous' , 'but delicious']
 * 
 *  multi([names, adjectives, but], Loop).iter( 
 *      function(i) trace 'A ${i[1]} ${i[2]} ${i[0]}' 
 *  );
 *  
 *  Yields:
 *      "A dubious but delicious biscuit"
 *      "A insane but delicious hat"
 *      "A gorgeous but delicious hammer"
 *  ```
 *
 *  When the iterables do not have the same count()
 *  ===============================================
 *
 *  What happens when the two iterable parameters do not have the same count?
 *  Let's first declare those 2 iterables of different sizes to demonstrate the 3 
 *  different options:
 *
 *  var trinidad    = ["pater",     "fili",     "spiritus"  ];
 *  var fruits      = ["banana",    "coconut",  "pineapple" ];
 *  var clothes     = ["bandana",   "bikini"                ];
 *
 *  Cut
 *  ---
 *  TODO: maybe rename to "Ignore"
 *  We can cut the iteration short as soon as one of the iterators finishes,
 *  (that is the default):
 *  
 *                                               // v------ optional
 *  for (i in new IterMulti([trinidad, fruits, clothes], Cut ))
 *      trace(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);
 *
 *          // "pater drinks banana juice wearing a bandana"
 *          // "fili drinks coconut juice wearing a bikini"
 *
 *  Null
 *  ----
 *  TODO: maybe this should be the DEFAULT
 *  Shorter iterators can return null after they have finished iterating:
 *
 *  for (i in new IterMulti([trinidad, fruits, clothes], Null ))
 *      trace(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);
 *
 *          // "pater drinks banana juice wearing a bandana"
 *          // "fili drinks coconut juice wearing a bikini"
 *          // "spiritus drinks pineapple juice wearing a null"
 *
 *  Loop
 *  ----
 *  Shorter iterators can be detected automatically and be 
 *  turned into loops:
 *
 *  for (i in new IterMulti([trinidad, fruits, clothes], Loop ))
 *      trace(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);
 *
 *          // "pater drinks banana juice wearing a bandana"
 *          // "fili drinks coconut juice wearing a bikini"
 *          // "spiritus drinks pineapple juice wearing a bandana"
 *
 *  Sustain
 *  -------
 *  Shorter iterators, instead of looping or returning null, will just repeat
 *  their last value.
 *
 *  Random
 *  ------
 *  Shorter iterators instead of looping or returning null, will return any 
 *  random value that they had previously returned.
 *
 *  All these shortcomings are simple enough to use, but there are more advanced
 *  ways to use this class.
 *
 * [ADVANCED] combinations with other iterators
 * ============================================
 * 
 * Cut, Null, Loop etc are simple but can not cover all the use-cases with 
 * IterMulti. However we can combine entry iterables with infinite 
 * iterators from this library such as loop(), sustain(), pingpong(), 
 * combinations such as meet(n).loop(), partition(n).loop() 
 * or even non-infinite iterators like dup() to cover these.
 *
 * Once we know how to use them, these hybrid Iterables/Iterators can be
 * combined. We can describe a lot without having to write a single loop.
 * E.g.:
 *
 *  import IterLoop.loop as loop;
 *  import IterMulti.multi as multi;
 *  import IterSustain.sustain as sustain;
 *
 *  var trinidad    = ["pater",     "fili",     "spiritus"  ];
 *  var fruits      = ["banana",    "coconut"               ];
 *  var clothes     = ["bandana",                           ];
 * 
 *  // A simple example first:
 *
 *  // 3 finite iterables -----.             A shortcoming:
 *  //                .--------+--------.     "Loop" when subiterators !haveNext()
 *  //                |        |        |       |     
 *  //                v        v        v       v      v------- A precipitator
 *  var a = multi([trinidad, fruits, clothes], Loop).array();
 *
 *                  // Generated result is:
 *                  // a[0] is ["pater",   "banana",  "bandana" ]
 *                  // a[1] is ["fili",    "coconut", "bandana" ]
 *                  // a[2] is ["spiritus","banana",  "bandana" ]
 *
 *
 *  // /!\ 
 *  // Now we arrive at a seemingly simple example that is in fact much more 
 *  // powerful. 
 *  // Instead of using an explicit Shortcoming (Null, Loop, Sustain, Random), 
 *  // we will use infinite iterators from the library, and because we won't
 *  // specify a Shortcoming, the default will be to Cut to the largest iterator.
 *  // But as a matter of fact, IterMulti will Cut to the largest **finite** 
 *  // iterator, so we get away with having infinite cycles:
 *
 *  // This is an infinite IterLoop ---------------------.    precipitation
 *  // This is an infinite IterSustain --.               |       |
 *  // trinidad is finite-v              v               v       v
 *  var c = multi([trinidad, fruits.sustain(), clothes.loop()]).array();
 *
 *                  // The result:
 *                  // c[0] is ["pater",   "banana",  "bandana" ]
 *                  // c[1] is ["fili",    "coconut", "bandana" ] 
 *                  // c[2] is ["spiritus","coconut", "bandana" ] 
 *
 *  //   ^-- TL;DR
 *  //     ALL OF THE ITERATORS IN THIS LIBRARY, _FINITE_ OR _INFINITE_), 
 *  //     CAN BE USED, AND ITERMULTI WILL JUST KNOW WHAT TO DO. SOME POTENTIALLY
 *  //     COMPLEX STUFFS CAN BE DONE WITH THIS.
 *
 * More on that last example:
 *
 * Indeed, it would be problematic if we turned all of the entries to infinite 
 * iterators *and* if we called .array() on that (because it would 
 * precipitate the generation of an infinite array). But without writing .array(), 
 * we might just as well use that infinite combination of 3 inner infinite 
 * iterators inside another non-infinite expression (such as another iterator,
 * that could be embedded inside another one and so on), and just get away with it. 
 *
 * Our iterators don't get evaluated until we write stuffs such as .array() or 
 * .list(), until that point they are just expressions, they describe traversing 
 * and complex traversing of data that make up new data, and as long as we keep
 * this in mind and use compatible iterators, we just get away with a pretty 
 * powerful way of writing stuffs.
 *
 */
enum IterMultiShortcoming { 
    Cut;        ///< Iteration is cut short as soon as one of the iterators finishes
    Null;       ///< Iterators coming short return null until last iter finishes
    Loop;       ///< Iterators coming short will loop until last iter finishes
    Sustain;    ///< Same as null, except last non-null value is used 
    Random;     ///< Iterators coming short will return their past values randomly
                //// until the last iterator finishes
}

class IterMulti implements FinitudeIterable {
    var _a          :   Array<Iterable<Dynamic>>;
    var _its        :   Array<Iterator<Dynamic>>;
    var _loop       :   IterMultiShortcoming;
    var _areFin     :   Array<Bool>;    ///< Which one finished? False: not fin
    var _isInfinite :   Bool;
    var _areInfinite:   Array<Bool>;    ///< Some _its can be infinite. We need to
                                        ///< keep track of them so we don't enter
                                        ///< an infinite loop.
    var _lastVals   :   Array<Dynamic>; ///< Only whenever _loop = Sustain
    var _haveTheyNext : Array<Bool>;    ///<
    var _returns    :   Array<Dynamic>; ///< So not build a new array every iteration

    public function new(
            zit:Iterable<Iterable<Dynamic>>, 
            zloop:IterMultiShortcoming=null
    ) {
        _a = zit.array();
        _its = [ for (e in _a) e.iterator() ];
        _loop = zloop == null ? Cut : zloop;
        if (_loop == Sustain) _lastVals = [ for (i in 0..._its.length) null ];
        _areFin = []; 

        _isInfinite = _its.length > 0;      // temporarily. see 5 lines below

        _haveTheyNext = [];
        _returns = [];
        for (i in 0..._its.length) {
            _haveTheyNext.push(false);      // whatever the value here, we be recalc
            if (Std.is(_its[i], FinitudeIterable)
            && cast (_its[i], FinitudeIterable).isInfiniteIter()) {
                _areFin.push(true);
            }
            else {
                _areFin.push(false);
                _isInfinite = false;        
            }
        }
        _areInfinite = _areFin.copy();      // values will diverge later
    }

    public inline static function multi(
            zit:Iterable<Iterable<Dynamic>>, 
            zloop:IterMultiShortcoming=null
    ):IterMulti
        return new IterMulti(zit, zloop);

    public function next() {
        for (i in 0..._its.length) {
            var v = _its[i].next();
            if (_loop == Sustain) {
                if (v == null) _returns[i] = _lastVals[i];
                else {
                    _lastVals[i] = v;
                    _returns[i] = v;
                }
            }
            else _returns[i] = v;
        }
        return _returns;
    }

    public function hasNext() { 
        // we may use it.hasNext(), but better cache that
        // var haveTheyNext:Array<Bool> = [];  

        var allHaveNext  = true;
        var noneHaveNext = true;
        for (i in 0..._its.length)  {
            var it = _its[i];
            var b:Bool = it.hasNext();
            // v-- this because we want to discard infinite iterators
            if (!_areInfinite[i]) {
                allHaveNext  = allHaveNext && b;
                noneHaveNext = noneHaveNext && !b;
            }
            _haveTheyNext[i] = b;
        }
        switch (_loop) {
            case Null | Sustain: return !noneHaveNext;
            case Cut:            return allHaveNext;
            case Loop | Random:
               if (allHaveNext)  return true;
               if (noneHaveNext) return false;
               // At least one of them is finished and another one is not finished

               // Whichever are now finished that were not:
               //  .reset their iterator 
               //  .mark them in _areFin
            
               for (i in 0..._areFin.length) {
                   if (!_haveTheyNext[i] && !_areFin[i]) { 
                        _areFin[i] = true;
                        if (_loop == Loop) _its[i] = _a[i].iterator(); 
                        else _its[i] = new IterRandom(_a[i], true);
                   }
               }

               if (_allNonLoopingOnesAreFinishedOrAllAreNowLooping()) 
                    return false;

               // Reset those which !hasNext() and are already looping
               for (i in 0..._haveTheyNext.length) {
                   if (!_haveTheyNext[i] && _areFin[i]) {
                       if (_loop == Loop) _its[i] = _a[i].iterator();
                       else _its[i] = new IterRandom(_a[i], true);
                   }
               }
               return true;
        }
    }

    private inline function _allNonLoopingOnesAreFinishedOrAllAreNowLooping():Bool {
        var doThey = true;
        var areTheyAllLooping = true;
        for (i in 0..._areFin.length) {
            doThey = doThey     
                && !_areFin[i] 
                && !_haveTheyNext[i]
            ;
            areTheyAllLooping = areTheyAllLooping && _areFin[i];
        }
        return doThey || areTheyAllLooping;
    }

    public function iterator() return new IterMulti(_a, _loop);
    public function isInfiniteIter() return _isInfinite;
    
}

