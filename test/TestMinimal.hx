import TestMinimal.IterChain2.chain as chain;
using Lambda;
import TestMinimal.IterRange.range as range;
import TestMinimal.IterRange.rangeDown as rangeDown;

// NO ERROR If next line is commented out (same whether
// all classes sit or not in the same file).
using TestMinimal.IterChain2;

// Otherwise if previous line is not commented, these errors show:
// IterChain2.hx:14: characters 27-30 : TestTest should be Iterable<Unknown<0>>
// IterChain2.hx:14: characters 27-30 : TestTest should be { iterator : Void -> Iterator<Unknown<0>> }
// IterChain2.hx:14: characters 27-30 : TestTest has no field iterator
// IterChain2.hx:14: characters 27-30 : For function argument 'a'
// TestTest.hx:30: lines 30-34 : Called from macro here

class IterFoo {
    public function new() {}
    public function next() return null;
    public function hasNext() return false;
    public function iterator() return this;
}
class IterBar {
    public function new() {}
    public function next() return null;
    public function hasNext() return false;
    public function iterator() return this;
}

class TestMinimal {
    public static function main() {
        chain(
            new IterFoo(),
            new IterBar()
        ).fold( function (x,i) return x+i, 0 );

        chain(
            new IRU(0,10),
            new IRD(100,89)
        ).fold( function (x,i) return x+i, 0 );

        chain(
            range(0,10),
            rangeDown(100,89)
        ).fold( function (x,i) return x+i, 0 );
    }

}


class IterChain2<T> {
    public function new(a:Array<Iterable<T>>) { trace(a); }
    
    public macro static function chain<T>(arr:Array<haxe.macro.Expr>) {
        var a = [];
        for (e in arr) { a.push(e); }
        var args = macro $a{a};
        return macro new IterChain2($args);
    }

    public inline function next() return null;
    public function hasNext() return false;
    public function iterator() return this;
}



class IterRange<T:Float> {
    public static inline function range<T:Float>(a:T, b:T) 
        return new IRU(a, b);
    public inline static function rangeDown<T:Float>(a:T, b:T) 
        return new IRD(a, b);
}

// some stupid range iterator
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

// some stupid reverse range iterator
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

