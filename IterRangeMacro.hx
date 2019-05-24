package finitudeiterable;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.ExprTools;
using haxe.macro.ComplexTypeTools;

/**
 * Same as IterRange, using macros to optimize compiled code based
 * on the parameters, so it actually can run with less overhead (= Faster).
 *
 *
 * Example:
 * ```haxe
 * for (i in new IterRangeMacro(10, -4.5, -.5))
 *      trace(i);
 *
 * import IterRangeMacro.rangeM as range;
 * ...
 * for (i in range(4, 10))
 *      trace(i);                   // 4, 5, 6, 7, 8, 9
 *
 * trace( range(0, 4).array() );    // [0,1,2,3]
 * ```
 */


/**
 * Most times, you want to use rangeM() and not new(). 
 * it will build an optimized inline version depending on the parameters.
 */
class IterRangeMacro<T:(Float)> {
    var ab : T;           ///< From
    var ad : T;           ///< To
    var d  : T;           ///< Step
    var n  : T;           ///< Next value to be returned (precomputed)


    /**
     * @note The recommanded way to use this class is through range().
     * @param (T from) The from value, this is always the first value iterated
     * @param (T to)   The to value. This is actually NEVER reached
     * @param (T step) The step. Sign doesn't matter here
     * @param (Bool reverseRange=false) Swap to and from but
     *              in that case, 1 will be substracted from both to and from:
     *               Eg range(0,3)        iterates through 0,1,2
     *                  range(0,3,_,true) iterates through 2,1,0
     *              but range(3,0)        iterates through 3,2,1)
     */
    public function new(from:T, to:T, step:T=cast 1, reverseRange:Bool=false) {
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
    public inline function iterator() return new IterRangeMacro<T>(ab, ad, d);
    
    /**
     * rangeM() uses macro. Worst case scenario it will use the generic rangeG(),
     *          but the macro will use the faster rangeUp(), rangeDown(), 
     *          rangeStepUp() or rangeStepDown() whenever possible 
     *          (that is, if constants are used, instead of variables).
     *
     * @param (T from) The from value, this is always the first value iterated
     * @param (T to)   The to value. This is actually NEVER reached
     * @param (T step) The step. Sign doesn't matter here
     * @param (Bool reverseRange=false) Swap to and from but
     *              in that case, 1 will be substracted from both to and from:
     *               Eg range(0,3)        iterates through 0,1,2
     *                  range(0,3,_,true) iterates through 2,1,0
     *              but range(3,0)        iterates through 3,2,1)
     *
     * For instance, this is one possible JS output for range(2, -1):
     *      var _g_ab = 2;
     *      var _g_ad = -1;
     *      var _g_n = _g_ab;
     *      while(_g_n > _g_ad) {
     *          var i = _g_n--;
     *      }
     *  (the new() has been inlined and the step variable doesn't appear)
     */
    macro public inline static function rangeM(
        from:           ExprOf<Float>, 
        to:             ExprOf<Float>, 
        ?step:          ExprOf<Float>,          // default: 1
        ?reverseRange:  ExprOf<Bool>            // default: false
    ) {
        // .Check whether maybe we just have constants, in that case
        //  call an optimized implementation, otherwise new Range
        var canOptim:Bool;
        try canOptim = (switch (from.expr) {
            case EConst(CInt(_))
               | EConst(CFloat(_)): true;
            default: false;
        }) && (switch (to.expr) {
            case EConst(CInt(_))
               | EConst(CFloat(_)): true;
            default: false;
        }) && (switch (step.expr) {
            case EConst(CInt(_))
               | EConst(CFloat(_))
               | EConst(CIdent("null")): true;
            default: false;
        }) && (switch (reverseRange.expr) {
            case EConst(CIdent("true"))
               | EConst(CIdent("false"))
               | EConst(CIdent("null")): true;
            default: false;
        }) catch (s:String) canOptim = false;
        
        var areAllInts:Bool;
        // trace(haxe.macro.Context.unify(haxe.macro.Context.typeof(to), (macro:Int).toType()));
        try areAllInts = (switch (from.expr) {
            case EConst(CInt(_)): true;
            case EConst(CIdent(_)): 
                Context.unify(Context.typeof(from), (macro:Int).toType());
            default: false;
        }) && (switch (to.expr) {
            case EConst(CInt(_)): true;
            case EConst(CIdent(_)): 
                Context.unify(Context.typeof(to), (macro:Int).toType());
            default: false;
        }) && (switch (step.expr) {
            case EConst(CInt(_))
               | EConst(CIdent("null")): true;
            default: false;
        }) catch (s:String) areAllInts = false;

        var isExpectedInt = switch(haxe.macro.Context.getExpectedType()) {
            case TInst(_.get() => {pack:[], name:"Int"}, []): true;
            default: false;
        };
        var t = areAllInts || isExpectedInt
            ? (macro : Int) 
            : (macro : Float)
        ;
        if (!canOptim) {
            return macro IterRange.rangeG($from, $to, $step, $reverseRange);
        }

        // .Identify default values
        if (step.getValue() == null) step = macro 1.;
        if (reverseRange.getValue() == null) reverseRange = macro false;

        // .Swap from and to if necessary
        var a = cast from.getValue();
        var b = cast to.getValue();
        if (reverseRange.getValue() == true) {
            var t = a - 1;
            a = b - 1;
            b = t;
            from = macro $v{a};
            to = macro $v{b};
        }

        // .Adjust sign of step if nec.
        var d = cast step.getValue();
        if (d == 0) throw "IterRangeMacro.range: a step of 0 is not allowed (infinite loop)";
        if (a > b && d > 0 || a < b && d < 0) d = -d;

        macro var step:$t = macro $v{d};
        // trace('a:$a b:$b d:$d $step');
        
        // Not using specialized inline classes would simply return:
        //      return macro new IterRangeMacro($from, $to, $step); 
        // Instead we'll use specialized macros:
        if (Math.abs(d) == 1) {
            if (d < 0)  return macro IterRange.rangeDown($from, $to);
            else        return macro IterRange.range($from, $to);
        }
        else {
            if (d < 0)  return macro IterRange.rangeStepDown($from, $to, cast $v{d});
            else        return macro IterRange.rangeStep($from, $to, cast $v{d});
        }
    }
}

