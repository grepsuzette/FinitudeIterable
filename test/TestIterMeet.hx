import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import IterRange.range as range;

using Lambda;
using IterMeet;

class TestIterMeet extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterMeet());
        runner.run();
    }

    public function compareArrays<T>(a:Array<T>, b:Array<T>):Bool {
        if (a.length != b.length) return false;
        for (i in 0...a.length) if (a[i] != b[i]) return false;
        return true;
    }

    public function valuesAreAllUnique<T>(a:Array<T>):Bool {
        for (i in 0...a.length-1)
            for (j in i+1...a.length)
                if (a[i] == a[j]) return false;
        return true;
    }
    
    public function test_seq2idx_builder() {
        for (i in 1...10) {
            var nbIter = 1 << i;
            var a = IterMeet.precalcKeyFromSeq(nbIter);
            assertTrue(valuesAreAllUnique(a));
            assertEquals(a.length, nbIter);
        }
    }

    public function test_meet0() {
        assertTrue( compareArrays( 
            [0,1,2,3,4,5,6,7,8,9].iterMeet(0).array(),
            [0,1,2,3,4,5,6,7,8,9]
        ));
    }

    public function test_meet1() {
        assertTrue( compareArrays( 
            [0,1,2,3,4,5,6,7,8,9].iterMeet(1).array(),
            [0,9,1,8,2,7,3,6,4,5]
        ));
    }

    public function test_meet2() {
        assertTrue( compareArrays( 
            [for (i in 0...14) i].iterMeet(2).array(),
            [0,13,4,10,1,12,5,9,2,11,6,8,3,7]
        ));
    }

    public function test_moreIteratorsThanValuesStillWorks() {
        for (order in -12...12) {
            var a = range(0,14).array().iterMeet(order).array();

            // trace('order $order for 1..14:' + a);
            assertEquals(a.length, 14);
            assertTrue(valuesAreAllUnique(a));
            for (e in a)
                assertFalse(e == null);
        }
    }

    public function test_lets_go_n_crazy() {
        var a = [0,1,2,3,4,5,6];
        for (n in 1...7) {
            var built = a.iterMeet(n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }

    public function test_lets_go_more_n_crazy() {
        var a = [ for (i in 0...500) i ];
        for (n in 2...6) {
            var built = a.iterMeet(n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }

    public function test_lets_go_even_more_n_crazy() {
        var a = [ for (i in 0...500) i ];
        for (n in new IterRange(2, 8, 2)) {
            var built = a.iterMeet(n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }

    public function test_negative_order1() {
        assertTrue(compareArrays(
            [0,1,2,3,4,5,6,7,8,9].iterMeet(-1).array(),
            [4,5,3,6,2,7,1,8,0,9]
        ));
    }

    public function test_negative_order2() {
        assertTrue(compareArrays(
            [0,1,2,3,4,5,6,7,8,9].iterMeet(-2).array(),
            [2,8,5,6,1,9,4,7,0,3]       
        ));
    }

    public function test_lets_go_n_crazy_negative_order() {
        var a = range(25,-25).array();
        for (n in 1...7) {
            var built = a.iterMeet(-n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }

} 
