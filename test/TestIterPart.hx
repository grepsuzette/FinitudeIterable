import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using Lambda;
using IterPart;

class TestIterPart extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterPart());
        runner.run();
    }

    public function test_order0isempty() {
        var mozart = "WOLFGANG AMADEUS MOZART";
        assertEquals(mozart.split("").iterPart(0).array().length, 0);
    }

    public function test_1() {
        var mozart = "WOLFGANG AMADEUS MOZART";
        assertEquals(mozart.split("").iterPart(1).array().join(""), mozart);
        assertEquals(mozart.split("").iterPart(2).array().join(""), "WAODLEFUGSA NMGO ZAAMRT");
        for (n in 1...mozart.length) 
            // trace(mozart.split("").iterPart(n).array().join(""));
        assertEquals(mozart.split("").iterPart(mozart.length).array().join(""), mozart);
    }

    public function test_reverse_order() {
        var mozart = "WOLFGANG AMADEUS MOZART";
// trace(mozart.split("").iterPart(-1).array().join(""));
        var trazom = mozart.split("");
        trazom.reverse();
        assertEquals(mozart.split("").iterPart(-1).array().join(""), 
trazom.join(""));
        assertEquals(
            "MOZART".split("").iterPart(-2).array().join(""),
            "ZTORMA"
        );
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

    public function test_lets_go_n_crazy() {
        var a = [0,1,2,3,4,5,6];
        for (n in 1...30) {
            var built = a.iterPart(n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }

    public function test_lets_go_more_n_crazy() {
        var a = [ for (i in 0...500) i ];
        for (n in 2...10) {
            var built = a.iterPart(n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }

    public function test_lets_go_even_more_n_crazy() {
        var a = [ for (i in 0...500) i ];
        for (n in new IterRange(2, 100, 10)) {
            var built = a.iterPart(n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }

    public function test_lets_go_even_more_n_crazy_again() {
        var a = [ for (i in 0...500) i ];
        for (n in new IterRange(2, 1000, 90)) {
            var built = a.iterPart(n).array();
            // trace('$n:  $built');
            assertEquals(built.length, a.length);
            assertTrue(valuesAreAllUnique(built));
        }
    }
} 


