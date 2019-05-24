/*
As of 

Results for 1 million iterations (resulting in 2 million):
----------------------------------------------------------

- A simple iterator (i...times) dos(a[i]) + dos(b[i]): 1264ms
- DualIterator dos(i) + dos(j): 2031ms
- for (i in dual(a,b)) dos(i._1) + dos(i._2): 2030ms
-63: -------------------
- Direct iteration (i...times) dos(i): 527ms
- Order(2) Meet iteration (i...times) dos(i): 3114ms
- Order(-2) Meet iteration (i...times) dos(i): 3120ms
- Order(3) Meet iteration (i...times) dos(i): 2892ms
- Order(4) Meet iteration (i...times) dos(i): 2791ms

- Order(1) Part iteration (i...times) dos(i): 4229ms
- Order(2) Part iteration (i...times) dos(i): 3435ms
- Order(3) Part iteration (i...times) dos(i): 3148ms
- Order(4) Part iteration (i...times) dos(i): 3030ms

Conclusion
------------
No problem here, it is even surprisingly fast 
considering how many inner iterators are used for these
(IterRange, IterArmy)
*/

import Chrono;
import IterRange;
import IterRange.range as range;
using Lambda;
import IterDual.dual as dual;

/**
 * This benchmark aim at determining
 * how much overhead is brought with the composite iterators:
 *  Army
 *  Dual
 *  Multi
 *  Meet
 *  Part
 *
 * Run also the `haxe compositevstinkvsinline.hxml`
 *   for more tests comparing with (the superior) tink approach
 *   and IterMulti.
 */
class BenchComposite {
    
    public static function main() {
        test_dual(1000 * 1000);
        test_meet_and_part(1000 * 1000);
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

        ch.stop();
    }

    public static function test_meet_and_part(times:Int) {
        trace("-------------------");
        var a = range(0, times).array();
        var ch = new Chrono("_");

        ch.ss("Direct iteration (i...times) dos(i)");
        for (i in a) {
            doSomething(i);
        }
        
        ch.ss("Order(2) Meet iteration (i...times) dos(i)");
        for (i in new IterMeet(a, 2)) {
            doSomething(i);
        }

        ch.ss("Order(-2) Meet iteration (i...times) dos(i)");
        for (i in new IterMeet(a, -2)) {
            doSomething(i);
        }

        ch.ss("Order(3) Meet iteration (i...times) dos(i)");
        for (i in new IterMeet(a, 3)) {
            doSomething(i);
        }

        ch.ss("Order(4) Meet iteration (i...times) dos(i)");
        for (i in new IterMeet(a, 4)) {
            doSomething(i);
        }

        ch.ss("Order(1) Part iteration (i...times) dos(i)");
        for (i in new IterPart(a, 1)) {
            doSomething(i);
        }

        ch.ss("Order(2) Part iteration (i...times) dos(i)");
        for (i in new IterPart(a, 2)) {
            doSomething(i);
        }

        ch.ss("Order(3) Part iteration (i...times) dos(i)");
        for (i in new IterPart(a, 3)) {
            doSomething(i);
        }

        ch.ss("Order(4) Part iteration (i...times) dos(i)");
        for (i in new IterPart(a, 4)) {
            doSomething(i);
        }

        ch.stop();
    }
}




