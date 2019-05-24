
import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using IterRange;
using IterLoop;
using Lambda;

class TestIterPingPong extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterPingPong());
        runner.run();
    }

    public function test_pingpong0() {
        var a = [1,2,3].iterPingPong(0).array();
        assertEquals(a.length, 0);
    }

    public function test_pingpong1() {
        var a = [1,2,3].iterPingPong(1).array();
        assertEquals(a.length, 6);
        assertEquals(a[0], 1);
        assertEquals(a[1], 2);
        assertEquals(a[2], 3);
        assertEquals(a[3], 3);
        assertEquals(a[4], 2);
        assertEquals(a[5], 1);
    }

    public function test_pingpong2() {
        var a = [1,2,3].iterPingPong(2).array();
        assertEquals(a.length, 12);
        assertEquals(a[0], 1);
        assertEquals(a[1], 2);
        assertEquals(a[2], 3);
        assertEquals(a[3], 3);
        assertEquals(a[4], 2);
        assertEquals(a[5], 1);
        assertEquals(a[6], 1);
        assertEquals(a[7], 2);
        assertEquals(a[8], 3);
        assertEquals(a[9], 3);
        assertEquals(a[10], 2);
        assertEquals(a[11], 1);
    }

    // Negative

    public function test_pingpongMinus1() {
        var a = [1,2,3].iterPingPong(-1).array();
        assertEquals(a.length, 6);
        assertEquals(a[0], 3);
        assertEquals(a[1], 2);
        assertEquals(a[2], 1);
        assertEquals(a[3], 1);
        assertEquals(a[4], 2);
        assertEquals(a[5], 3);
    }

    public function test_pingpongMinus2() {
        var a = [1,2,3].iterPingPong(-2).array();
        var i = 0;
        assertEquals(a.length, 12);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 3);
    }

    public function test_pingpongMinus3() {
        var a = [1,2,3].iterPingPong(-3).array();
        var i = 0;
        assertEquals(a.length, 18);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 3);
    }

    // Infinities

    public function test_pingpong_ninfinity() {
        var a = [];
        var i = 10;
        for (x in [1,2,3].iterPingPong(-IterLoop.INFINITY)) {
            a.push(x);
            if (i-- < 0) break;
        }
        assertEquals(a.length, 12);
        assertEquals(a[0], 3);
        assertEquals(a[1], 2);
        assertEquals(a[2], 1);
        assertEquals(a[3], 1);
        assertEquals(a[4], 2);
        assertEquals(a[5], 3);
        assertEquals(a[6], 3);
        assertEquals(a[7], 2);
        assertEquals(a[8], 1);
        assertEquals(a[9], 1);
        assertEquals(a[10], 2);
        assertEquals(a[11], 3);
    }
    
    public function test_pingpong_infinity() {
        var a = [];
        var i = 10;
        for (x in [1,2,3].iterPingPong(IterLoop.INFINITY)) {
            a.push(x);
            if (i-- < 0) break;
        }
        assertEquals(a.length, 12);
        assertEquals(a[0], 1);
        assertEquals(a[1], 2);
        assertEquals(a[2], 3);
        assertEquals(a[3], 3);
        assertEquals(a[4], 2);
        assertEquals(a[5], 1);
        assertEquals(a[6], 1);
        assertEquals(a[7], 2);
        assertEquals(a[8], 3);
        assertEquals(a[9], 3);
        assertEquals(a[10], 2);
        assertEquals(a[11], 1);
    }

}

