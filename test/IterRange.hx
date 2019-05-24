// import haxe.macro.Expr;
// import haxe.macro.Context;
// using haxe.macro.ExprTools;
// using haxe.macro.ComplexTypeTools;

class IterRange<T:Float> {
    public static inline function range<T:Float>(a:T, b:T) return new IterRange.IRU(a, b);
    public inline static function rangeDown<T:Float>(a:T, b:T) return new IterRange.IRD(a, b);
}


class IRU<T:(Float)> { // IterRangeUp, step 1
    var ab : T;      ///< From
    var ad : T;      ///< To
    var n  : T;      ///< Next value to be returned (precomputed)

    public inline function new(from:T, to:T) {
        ab = from;
        ad = to;
        n  = ab;
    }
    public inline function hasNext()    return n < ad; 
    public inline function next()       return n++;
    public inline function iterator()   return new IRU(ab, ad);
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
    public inline function iterator()   return new IRD(ab, ad);
}

