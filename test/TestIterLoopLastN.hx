import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using IterLoopLastN;
using Lambda;

class TestIterLoopLastN extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterLoopLastN());
        runner.run();
    }

    public function test_infinite() {
        var i = 0;
        var a = [];
        for (s in ["fish", "monkey", "human"].loopLastN(2)) {
            a.push(s);
            if (++i >= 10) break;
        }
        assertEquals( a.length, 10 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "human" );
        assertEquals( a[3], "monkey" );
        assertEquals( a[4], "human" );
        assertEquals( a[5], "monkey" );
        assertEquals( a[6], "human" );
        assertEquals( a[7], "monkey" );
        assertEquals( a[8], "human" );
        assertEquals( a[9], "monkey" );
    }

    public function test_infiniteNLargerThanLength() {
        var i = 0;
        var a = [];
        for (s in ["fish", "monkey", "human"].loopLastN(8)) {
            a.push(s);
            if (++i >= 10) break;
        }
        assertEquals( a.length, 10 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "human" );
        assertEquals( a[3], "fish" );
        assertEquals( a[4], "monkey" );
        assertEquals( a[5], "human" );
        assertEquals( a[6], "fish" );
        assertEquals( a[7], "monkey" );
        assertEquals( a[8], "human" );
        assertEquals( a[9], "fish" );
    }

    public function test_infinite_1() {
        var i = 0;
        var a = [];
        for (s in ["fish", "monkey", "human"].loopLastN(1)) {
            a.push(s);
            if (++i >= 10) break;
        }
        assertEquals( a.length, 10 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "human" );
        assertEquals( a[3], "human" );
        assertEquals( a[4], "human" );
        assertEquals( a[5], "human" );
        assertEquals( a[6], "human" );
        assertEquals( a[7], "human" );
        assertEquals( a[8], "human" );
        assertEquals( a[9], "human" );
    }

    public function test_finite() {
        var a = [];
        for (s in ["fish", "monkey", "boing"].loopLastN(2, 1)) {
            a.push(s);
        }
        assertEquals( a.length, 5 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "boing" );
        assertEquals( a[3], "monkey" );
        assertEquals( a[4], "boing" );
    }
    
    public function test_zero() {
        var a = [];
        for (s in ["fish", "monkey", "boing"].loopLastN(2, 0)) a.push(s);
        assertEquals(a.length, 3);
        
        assertEquals( ["fish", "monkey", "boing"].loopLastN(2, 0).array().length, 3);
    }

    public function test_finiteNLargerThanLength() {
        // When n is larger than length,
        // it should loop the available elements instead.
        var a = [];
        for (s in ["fish", "monkey", "boing"].loopLastN(6, 1)) {
            a.push(s);
        }
        assertEquals( a.length, 6 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "boing" );
        assertEquals( a[3], "fish" );
        assertEquals( a[4], "monkey" );
        assertEquals( a[5], "boing" );
    }


    // Negative loops
    public function test_minus() {
        var a = [];
        for (s in ["fish", "monkey", "boing"].loopLastN(2, -2)) {
            a.push(s);
        }
        assertEquals(a.length, 7);
        assertEquals(a[0], "fish");
        assertEquals(a[1], "monkey");
        assertEquals(a[2], "boing");
        assertEquals(a[3], "boing");
        assertEquals(a[4], "monkey");
        assertEquals(a[5], "boing");
        assertEquals(a[6], "monkey");
    }

    public function test_minus2() {
        var a = [];
        for (s in [0,1,2,3,4,5,6,7,8,9].loopLastN(3, -2)) {
            a.push(s);
        }
        assertEquals(a.length, 16);
        assertEquals(a[0], 0);
        assertEquals(a[1], 1);
        assertEquals(a[2], 2);
        assertEquals(a[3], 3);
        assertEquals(a[4], 4);
        assertEquals(a[5], 5);
        assertEquals(a[6], 6);
        assertEquals(a[7], 7);
        assertEquals(a[8], 8);
        assertEquals(a[9], 9);
        assertEquals(a[10], 9);
        assertEquals(a[11], 8);
        assertEquals(a[12], 7);
        assertEquals(a[13], 9);
        assertEquals(a[14], 8);
        assertEquals(a[15], 7);
    }

    public function test_minusInfinity() {
        var a = [];
        var i = 0;
        for (s in [4,5,6].loopLastN(2, IterLoopLastN.NINFINITY)) {
            a.push(s);
            if (++i >= 8) break;
        }
        assertEquals(a.length, 8);
        assertEquals(a[0], 4);
        assertEquals(a[1], 5);
        assertEquals(a[2], 6);
        assertEquals(a[3], 6);
        assertEquals(a[4], 5);
        assertEquals(a[5], 6);
        assertEquals(a[6], 5);
        assertEquals(a[7], 6);
    }

    public function test_minusInfinity2() {
        var a = [];
        var i = 0;
        for (s in [4,5,6,7,8,9].loopLastN(3, IterLoopLastN.NINFINITY)) {
            a.push(s);
            if (++i >= 25) break;
        }
        assertEquals(a.length, 25);
        assertEquals(a[0], 4);
        assertEquals(a[1], 5);
        assertEquals(a[2], 6);
        assertEquals(a[3], 7);
        assertEquals(a[4], 8);
        assertEquals(a[5], 9);
        assertEquals(a[6], 9);
        assertEquals(a[7], 8);
        assertEquals(a[8], 7);
        assertEquals(a[9], 9);
        assertEquals(a[10], 8);
        assertEquals(a[11], 7);
        assertEquals(a[12], 9);
        assertEquals(a[13], 8);
        assertEquals(a[14], 7);
        assertEquals(a[15], 9);
        assertEquals(a[16], 8);
        assertEquals(a[17], 7);
        assertEquals(a[18], 9);
        assertEquals(a[19], 8);
        assertEquals(a[20], 7);
        assertEquals(a[21], 9);
        assertEquals(a[22], 8);
        assertEquals(a[23], 7);
        assertEquals(a[24], 9);
    }
}
