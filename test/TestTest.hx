#if macro
import haxe.macro.Expr;
#end
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

import TestTest.IterRange.range as range;
import TestTest.IterRange.rangeDown as rangeDown;
import TestTest.IterChain2.chain as chain;
using Lambda;

// NO ERROR If next line is commented out (same whether
// all classes sit or not in the same file).
using TestTest.IterChain2;

// Otherwise if previous line is not commented, these errors show:
// IterChain2.hx:14: characters 27-30 : TestTest should be Iterable<Unknown<0>>
// IterChain2.hx:14: characters 27-30 : TestTest should be { iterator : Void -> Iterator<Unknown<0>> }
// IterChain2.hx:14: characters 27-30 : TestTest has no field iterator
// IterChain2.hx:14: characters 27-30 : For function argument 'a'
// TestTest.hx:30: lines 30-34 : Called from macro here


class TestTest extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestTest());
        runner.run();
    }

    public function test1() {
        IterChain2.chain(
            range(0,   3  ),
            rangeDown(-10, -13),
            range(3,   6  )
        ).fold( function(x, i) return i += x, 0 );
        assertTrue(true);
    }

    public function test2() {
        chain(
            range(0,   3  ),
            rangeDown(-10, -13),
            range(3,   6  )
        ).fold( function(x, i) return i += x, 0 );
        assertTrue(true);
    }

    public function test3() {
        ([ range(0,   3  ),
          rangeDown(-10, -13),
          range(3,   6  )
        ] : Array<Dynamic>).chain().fold( function(x, i) return i += x, 0 );
        assertTrue(true);
    }
}



class IterChain2<T> {
    public function new(a:Array<Iterable<T>>) { trace(a); }
    
    // public macro static function chain<T>(arr:Array<haxe.macro.Expr>) {
    public macro static function chain<T>( 
        // Normally, `using` this class should not be done.
        // However if that happens, we can detect the :this that
        // is going to be passed in some cases, as the first argument:
        eMaybeThisOrAnArg: haxe.macro.ExprOf<Iterable<T>>,
        arr:Array<haxe.macro.Expr>
    ) {
        trace(arr[0]);
        var a = [];
        switch eMaybeThisOrAnArg {
            case macro @:this this: 
            case _: a.push(eMaybeThisOrAnArg);
        }
        for (e in arr) { 
            // switch e {
            //     case macro @:this this: 
            //     case _: a.push(e);
            // }
            a.push(e); 
        }
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

