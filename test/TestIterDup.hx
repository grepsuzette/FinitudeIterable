
import haxe.unit.TestRunner;
import haxe.unit.TestCase;
import IterRange.range as range;
import IterDual.dual as dual;

using IterRange;
using IterDual;
using IterDup;
using Lambda;

class TestIterDup extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterDup());
        runner.run();
    }

    public function test_dup_simple() {
        var a = [1,2,3].dup(3).array();
        assertEquals(a[0], 1);
        assertEquals(a[1], 1);
        assertEquals(a[2], 1);
        assertEquals(a[3], 2);
        assertEquals(a[4], 2);
        assertEquals(a[5], 2);
        assertEquals(a[6], 3);
        assertEquals(a[7], 3);
        assertEquals(a[8], 3);
    }

    public function test_dup_simple2() {
        var a = [1,2,3].dup().array();
        assertEquals(a[0], 1);
        assertEquals(a[1], 1);
        assertEquals(a[2], 2);
        assertEquals(a[3], 2);
        assertEquals(a[4], 3);
        assertEquals(a[5], 3);
    }

    public function test_dup_simple4() {
        var a = [1,2,3].dup(1).array();
        assertEquals(a[0], 1);
        assertEquals(a[1], 2);
        assertEquals(a[2], 3);
    }

    public function test_dup_simple5() {
        var a = [1,2,3].dup(0).array();
        assertEquals(a.length, 0);
    }
}

