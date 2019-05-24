package finitudeiterable;

import FinitudeIterable;
using Lambda;

/**
 * Iterate the values of an array randomly.
 * By default, all values are guaranteed to be returned once (and only once) until
 * the iteration finishes.
 *
 * However, the iterator can also be made infinite passing true in the constructor,
 * in which case the iteration will of course never finish of its own.
 *
 * ```haxe
 * using IterRandom;
 * for (x in [0,1,2,3,4,5].iterRandom())
 *      trace(x);       // e.g. 4,2,5,0,3,1 or 3,5,1,2,0 or ...
 *
 *
 * // Since IterRandom<T> is also an Iterable<T> you can also do:
 *
 * using Lambda;
 * using IterRandom;
 *
 * var good = [0,1,2,3,4,5].iterRandom().find( is_good_number );
 *
 * // Where is_good_number is a Int->Bool function.
 * // if the array is very large, it adds the benefit you won't have to 
 * // necessarily traverse it all, it will stop as soon as a number if found.
 * ```
 */
class IterRandom<T> implements FinitudeIterable {
    var a       : Array<T>;
    var r       : Array<Int>;               ///< Randomized indexes of a
    var k       : Int;                      ///< Current index in r
    var isInfin : Bool;                     ///< Is infinite iterator?

    public function new(ar:Iterable<T>, infinite:Bool=false) {
        if (ar == null) throw "null iter";
        if (Std.is(ar, FinitudeIterable) && untyped ar.isInfiniteIter()) 
            throw "Infinite iter can not be used with IterRandom";
        isInfin = infinite;
        a = Std.is(ar, Array) ? cast ar : ar.array();
        if (!isInfin) {
            k = 0;
            r = [ for (i in 0...a.length) i ];
            r.sort(function(a,b) return Math.random() >= .5 ? 1 : -1);
        }
    }

    public inline static function iterRandom<T>(ar:Array<T>, infinite:Bool=false) : IterableIterator<T>
        return new IterRandom(ar, infinite);

    public function next() return !isInfin ? a[r[k++]] : a[Std.random(a.length)];
    public inline function hasNext() return isInfin || k < a.length;
    public inline function iterator():IterableIterator<T> return new IterRandom(a, isInfin);
    public inline function isInfiniteIter() return isInfin;
}
