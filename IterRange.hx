package finitudeiterable;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.ExprTools;
using haxe.macro.ComplexTypeTools;

/**
 * Range iteratorS ( C's for(;;) loops style ).
 * Can run backwards, using Ints and Floats, and can have steps.
 *
 * Example:
 * ```haxe
 * import IterRange.range as range;
 * ...
 * for (i in range(4, 10))
 *      trace(i);                   // 4, 5, 6, 7, 8, 9
 *
 * trace( range(0, 4).array() );    // [0,1,2,3]
 * ```
 *
 *
 * IterRange<T> and other range iterators are Iterable<T> 
 * ------------------------------------------------------
 *
 * So Mr. Bean can do things like:
 *
 * ```haxe
 * import IterRange.rangeG as rangeG;
 * using IterDup;
 * using Lambda;
 *
 * trace( rangeG(10, -4.5, -5).array() );       // [10, 5, 0]
 *
 * for (x in rangeG(10, -4.5, 5).dup(2))
 *      trace(x);                               // [10, 10, 5, 5, 0, 0]
 *
 * rangeG(10, -4.5, 5).dup(2).iter( function(x) trace(x) );
 *                                              // [10, 10, 5, 5, 0, 0]
 *                                              // .iter() being in Lambda.hx
 * ```
 *
 * Consistency
 * -----------
 *
 * IterRange is consistent with Haxe range iterator (`...`) and most other languages
 * in that it will never reach the end value, so:
 * 
 *  range(0, 5)                 will iterate 0, 1, 2, 3, 4 (but not 5)
 *  rangeG(9, 10.2, 0.5)        will iterate 9, 9.5, 10    (but not 10.2 nor 10.5)
 *  rangeG(2, -2, 3 )           will iterate 2, -1         (but not -5)           
 *  range(2, 2)                 will not iterate
 *  range(-2, -2)               won't iterate either
 */


/**
 * A collection of static methods, plus the general rangeG() iterator.
 *
 * [OPTIMIZATION NOTES]
 * Please use range(), rangeDown(), rangeStep(), rangeStepDown() when possible.
 * Keep rangeG() for those cases where Mr. Bean trully needs a general 
 * way of iterating.
 *
 * range() runs roughly as fast as the Haxe iterator.
 * rangeG() has more overhead. because the next()/hasNext() can not be inlined
 *    in this case.
 *
 * (Initial goal was to write a generic, multi-usage range() function, using
 * macros, that would choose the optimal method. Turns out it was possible
 * (see the IterRangeMacro.rangeM() in the git history) 
 * but where variables were used instead of constants (e.g. range(0, to))
 * the macro could not know whether it was modified or not, which led to 
 * it using the slower generic rangeG(). In order to simplify things and reduce
 * surprises for the programmer IterRangeMacro was removed - 
 * Thu Mar 10 22:55:48 CST 2016)
 */
class IterRange<T:Float> {
    /**
     * Optimized range iterators.
     *
     * Eg: rangeDown(10, 0) and rangeUp(0, 10) have a step of 1 and are as fast as 
     * Haxe's ... IteratorInt.
     */
    public inline static function range<T:Float>(a:T, b:T) return new IterRange.IRU(a, b);
    public inline static function rangeDown<T:Float>(a:T, b:T) return new IterRange.IRD(a, b);

    /**
     * Optimized stepped range iterators.
     *
     * rangeStepDown(10, 0, 2) and rangeStep(0, 30, 3) have an arbitrary step
     *  (the sign is automatically calculated).
     * They are slower than rangeDown() and range().
     *
     * Mr. Bean may also use rangeG() which is generic, but which is not as fast.
     */
    public inline static function rangeStep<T:Float>(a:T, b:T, s:T) return new IterRange.IRSU(a, b, s);
    public inline static function rangeStepDown<T:Float>(a:T, b:T, s:T) return new IterRange.IRSD(a, b, s);

    /**
     * Generic range. It can go upwards or downwards,
     * can use an arbitrary step (which sign is automatically determined),
     * can use Int or Float regardless,
     * and a and b may be swapped.
     */
    public inline static function rangeG<T:Float>(a:T, b:T, s:T=cast 1., reverseRange:Bool=false) return new IterRange(a, b, s, reverseRange);


    // ---------- The rest of the class is just used by rangeG() -------------
    
    var ab : T;                     ///< From
    var ad : T;                     ///< To
    var d  : T;                     ///< Step
    var n  : T;                     ///< Next value to be returned (precomputed)

    /**
     * Note: Mr. Bean do not want to use this constructor directly.
     * Instead he calls either range(), rangeDown(), rangeStep(), 
     * rangeStepDown() or rangeG(). 
     *
     * rangeG() is the same as new IterRange().
     *
     * @param (T from) The from value, this is always the first value iterated
     * @param (T to)   The to value. This is actually NEVER reached
     * @param (T step) The step. Sign doesn't matter here
     * @param (Bool reverseRange=false) Swap to and from (mostly useless)
     */
    public function new(from:T, to:T, step:T=cast 1., reverseRange:Bool=false) {
        ab = !reverseRange ? from : to - 1;
        ad = !reverseRange ? to : from - 1; 
        d  = step;
        if (ab > ad && d > 0.) d = -d;
        else if (ab < ad && d < 0.) d = -d;
        n  = ab;
    }


    public inline function hasNext() return ab <= ad ? n < ad : n > ad; 
    public inline function next() { var p = n; n += d; return p; }

    /** Making it an iterable: Must return a new iterator,
     *  so as to enable loops (see IterLoop), otherwise it would just
     *  continue iterating.
     */
    public inline function iterator():IterableIterator<T> return new IterRange<T>(ab, ad, d);
} // class IterRange



/**
 * @note Use the range(), rangeDown(), rangeStep() etc instead of these.
 */
class IRU<T:(Float)> { // IterRangeUp, step 1
    var ab : T;      ///< From
    var ad : T;      ///< To
    var n  : T;      ///< Next value to be returned (precomputed)

    // need inline otherwise slower thann Haxe  ... iterator
    // (due to having to access object.var instead of inlined var directly)
    // this costs a few bytes though, and as soon as we'd use it as an 
    // Iterable, the object would be created.
    public inline function new(from:T, to:T) {
        ab = from;
        ad = to;
        n  = ab;
    }
    public inline function hasNext()    return n < ad; 
    public inline function next()       return n++;
    public inline function iterator():IterableIterator<T>   return new IRU(ab, ad);
}

class IRD<T:(Float)> { // IterRangeDown, step -1
    var ab : T;       ///< From
    var ad : T;       ///< To
    var n  : T;       ///< Next value to be returned (precomputed)

    public inline function new(from:T, to:T) {
        ab = from;
        ad = to;
        n  = ab;
    }
    public inline function hasNext()    return n > ad; 
    public inline function next()       return n--;
    public inline function iterator():IterableIterator<T>   return new IRD(ab, ad);
}

class IRSU<T:(Float)> { // IterRangeStepUp, step >0
    var ab : T;       ///< From
    var ad : T;       ///< To. Will be -= d so everythg is optim away.
    var d  : T;       ///< Step
    var n  : T;       ///< Next value to be returned (precomputed)

    public inline function new(from:T, to:T, step:T) {
        d  = step;
        ab = from;
        ad = to - d;
        n  = ab - d;
    }
    public inline function hasNext()    return n < ad; 
    public inline function next()       return n += d;
    public inline function iterator():IterableIterator<T>   return new IRSU(ab, ad+d, d);
}

class IRSD<T:(Float)> { // IterRangeStepDown, step <0
    var ab : T;      ///< From
    var ad : T;      ///< To
    var d  : T;      ///< Step. Must be negative.
    var n  : T;      ///< Next value to be returned (precomputed)

    public inline function new(from:T, to:T, step:T) {
        d  = step;
        ab = from;
        ad = to - d;
        n  = ab - d;
        // trace('from:$from to:$to step:$step ab:$ab ad:$ad d:$d n:$n');
    }
    public inline function hasNext()    return n > ad; 
    public inline function next()       return n += d; 
    public inline function iterator():IterableIterator<T>   return new IRSD(ab, ad+d, d);
}

