/*
This tests requires tink_lang and its dependencies.
Run test with `haxe compositevstinkvsinline.hxml`

As of  Wed Mar 16 17:38:34 CST 201  6

Results for 1 million iterations (resulting in 2 million):
----------------------------------------------------------

- A simple iterator (i...times) dos(a[i]) + dos(b[i]): 1263ms
- DualIterator dos(i) + dos(j): 2074ms
- for (i in dual(a,b)) dos(i._1) + dos(i._2): 2042ms
- [TINK_LANG] for ([i in a, k in b])) dos(i) + dos(k): 1280ms
-nkVsInline.hx:70: ----- Dual with fallback/loop -------
- A simple iterator (i...times) dos(a[i]) + dos(b[i]) with fallback: 1002ms
- DualIterator dos(i) + dos(j) with fallback (loop): 2079ms
- [TINK_LANG] for ([i in a || 0, k in b || 0])) dos(i) + dos(k): 1385ms
-nkVsInline.hx:95: Multi iterators
- A simple iterator (i...times) dos(a[i]) + dos(b[i]) + dos(c[i]: 1767ms
- IterMulti dos(i) + dos(j) + dos(k): 18693ms
- for (i in multi(a,b)) ..: 18664ms
- [TINK_LANG] for ([i in a, j in b, k in c])) ...: 1784ms

Conclusion
------------
Tink approach (macros) obviously works best here.
Dual is still usable for projects without tink_lang.
Multi is AWFULLY slow (feature creep...). 
Better put a warning in it!
*/

import Chrono;
import IterRange;
import IterRange.range as range;
import IterDual.dual as dual;
import IterMulti.multi as multi;
import IterDual.dualLoop as dualLoop;
using Lambda;
using tink.CoreApi;

/**
 * This benchmark aim at determining
 * how much overhead is brought with the composite iterators:
 *  Army
 *  Dual
 *  Multi
 *  Meet
 *  Part
 */
@:tink class BenchCompositeVsTinkVsInline {
    
    public static function main() {
        // test_dual(1000 * 1000);
        // test_dual_with_fallback(1000 * 1000);
        // test_multi(1000 * 1000);
        test_multi_with_fallbacks(1000 * 1000);
    }

    public static inline function doSomething(i:Int)
        return (i + 432) * 2523 + i - (25*i);

    public static function test_dual(times:Int) {
        var ch = new Chrono("_");
        var a : Array<Int> = [ for (i in 0...times) i ];
        var b : Array<Int> = [ for (i in 0...times) times - i ];
        var c : Array<Int> = [ for (i in 0...times) 50 + i ];

        ch.ss("A simple iterator (i...times) dos(a[i]) + dos(b[i])");
        for (i in 0...times) {
            doSomething(a[i]) + doSomething(b[i]);
        }

        ch.ss("DualIterator dos(i) + dos(j)");
        for (i in new IterDual(a, b)) {
            doSomething(i._1) + doSomething(i._2);
        }

        ch.ss("for (i in dual(a,b)) dos(i._1) + dos(i._2)");
        for (i in dual(a, b)) {
            doSomething(i._1) + doSomething(i._2);
        }

        ch.ss("[TINK_LANG] for ([i in a, k in b])) dos(i) + dos(k)");
        for ([i in a, k in b]) {
            doSomething(i) + doSomething(k);
        }
        ch.stop();
    }

    public static function test_dual_with_fallback(times:Int) {
        trace("----- Dual with fallback/loop -------");
        var ch = new Chrono("_");
        var a : Array<Int> = [ for (i in 0...times) i ];
        var b : Array<Int> = [ for (i in 0...Std.int(times/6)) times - i ];
        var c : Array<Int> = [ for (i in 0...Std.int(times/2)) 50 + i ];

        ch.ss("A simple iterator (i...times) dos(a[i]) + dos(b[i]) with fallback");
        for (i in 0...times) {
              (i>=a.length ? 0 : doSomething(a[i])) 
            + (i>=b.length ? 0 : doSomething(b[i]));
        }

        ch.ss("DualIterator dos(i) + dos(j) with fallback (loop)");
        for (i in dualLoop(a, b)) {
            doSomething(i._1) + doSomething(i._2);
        }

        ch.ss("[TINK_LANG] for ([i in a || 0, k in b || 0])) dos(i) + dos(k)");
        for ([i in a || 0, k in b || 0]) {
            doSomething(i) + doSomething(k);
        }
        ch.stop();
    }

    public static function test_multi(times:Int) {
        trace("Multi iterators");
        var ch = new Chrono("_");
        var a : Array<Int> = [ for (i in 0...times) i ];
        var b : Array<Int> = [ for (i in 0...times) times - i ];
        var c : Array<Int> = [ for (i in 0...times) 50 + i ];

        ch.ss("A simple iterator (i...times) dos(a[i]) + dos(b[i]) + dos(c[i]");
        for (i in 0...times) {
            doSomething(a[i]) + doSomething(b[i]) + doSomething(c[i]);
        }

        ch.ss("IterMulti dos(i) + dos(j) + dos(k)");
        for (i in new IterMulti([a, b, c])) {
              doSomething(i[0]) 
            + doSomething(i[1])
            + doSomething(i[2]);
        }

        ch.ss("for (i in multi(a,b)) ..");
        for (i in multi([a, b, c])) {
              doSomething(i[0]) 
            + doSomething(i[1])
            + doSomething(i[2]);
        }

        ch.ss("[TINK_LANG] for ([i in a, j in b, k in c])) ...");
        for ([i in a, j in b, k in c]) {
            doSomething(i) + doSomething(k) + doSomething(j);
        }
        ch.stop();
    }

    public static function test_multi_with_fallbacks(times:Int) {
        trace("Multi iterators with fallbacks");
        var ch = new Chrono("_");
        var a : Array<Int> = [ for (i in 0...times) i ];
        var b : Array<Int> = [ for (i in 0...Std.int(times / 6)) times - i ];
        var c : Array<Int> = [ for (i in 0...Std.int(times / 2)) 50 + i ];

        ch.ss("A simple iterator (i...times) dos(a[i]) + dos(b[i]) + dos(c[i]");
        for (i in 0...times) {
            (i < a.length ? doSomething(a[i]) : 0)
          + (i < b.length ? doSomething(b[i]) : 0)
          + (i < c.length ? doSomething(c[i]) : 0);
        }

        ch.ss("IterMulti dos(i) + dos(j) + dos(k) with fallback (Sustain)");
        for (i in new IterMulti([a, b, c], Sustain)) {
              doSomething(i[0]) 
            + doSomething(i[1])
            + doSomething(i[2]);
        }

        ch.ss("for (i in multi(a,b)) with fallback (Loop)");
        for (i in multi([a, b, c], Loop)) {
              doSomething(i[0]) 
            + doSomething(i[1])
            + doSomething(i[2]);
        }

        ch.ss("[TINK_LANG] for ([i in a || 0, j in b || 0, k in c || 0])) with fallback");
        for ([i in a || 0, j in b || 0, k in c || 0]) {
            doSomething(i) + doSomething(k) + doSomething(j);
        }
        ch.stop();
    }
}




