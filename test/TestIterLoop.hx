import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using IterLoop;
using Lambda;

class TestIterLoop extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterLoop());
        runner.run();
    }

    public function test_loop0() {
        var a = [1,2,3].iterLoop(0).array();
        assertEquals(a.length, 0);
    }

    public function test_loop1() {
        var a = [1,2,3].iterLoop(1).array();
        assertEquals(a.length, 3);
        assertEquals(a[0], 1);
        assertEquals(a[1], 2);
        assertEquals(a[2], 3);
    }

    public function test_loop2() {
        var a = [1,2,3].iterLoop(2).array();
        assertEquals(a.length, 6);
        assertEquals(a[0], 1);
        assertEquals(a[1], 2);
        assertEquals(a[2], 3);
        assertEquals(a[3], 1);
        assertEquals(a[4], 2);
        assertEquals(a[5], 3);
    }

    public function test_infinite() {
        var sum = 0;
        for (x in [1,2,3].iterLoop()) {
            sum += x;
            assertTrue( x >= 1 );
            assertTrue( x <= 3 );
            if (sum >= 40) break;
            // trace('sum: $sum x:$x');
        }
        assertTrue(sum >= 40);
    }
    
    // backwards loops
    public function test_loop1_backwards() {
        var a = [1,2,3].iterLoop(-1).array();
        assertEquals(a.length, 3);
        assertEquals(a[0], 3);
        assertEquals(a[1], 2);
        assertEquals(a[2], 1);
    }

    public function test_loop1_backwards_with_list() {
        var a = new List<Int>();
        a.add(1);
        a.add(2);
        a.add(3);
        var b = a.iterLoop(-1).array();
        assertEquals(b.length, 3);
        assertEquals(b[0], 3);
        assertEquals(b[1], 2);
        assertEquals(b[2], 1);
    }

    public function test_loop2_backwards() {
        var a = [1,2,3].iterLoop(-2).array();
        assertEquals(a.length, 6);
        assertEquals(a[0], 3);
        assertEquals(a[1], 2);
        assertEquals(a[2], 1);
        assertEquals(a[3], 3);
        assertEquals(a[4], 2);
        assertEquals(a[5], 1);
    }

    public function test_infinite_backwards() {
        var sum = 0;
        for (x in [1,2,3].iterLoop(IterLoop.NINFINITY)) {
            sum += x;
            assertTrue( x >= 1 );
            assertTrue( x <= 3 );
            if (sum >= 40) break;
            // trace('sum: $sum x:$x');
        }
        assertTrue(sum >= 40);
    }

    public function test_infinite_backwards2() {
        var sum = 0;
        var a = [];
        for (x in [1,2,3].iterLoop(IterLoop.NINFINITY)) {
            // print(x);
            a.push(x);
            sum += x;
            assertTrue( x >= 1 );
            assertTrue( x <= 3 );
            if (sum >= 40) break;
            // trace('sum: $sum x:$x');
        }
        assertTrue(sum >= 40);
        assertEquals(a[0], 3);
        assertEquals(a[1], 2);
        assertEquals(a[2], 1);
        assertEquals(a[3], 3);
        assertEquals(a[4], 2);
        assertEquals(a[5], 1);
    }
    
    // Some testing needs also to be done about IterArmy
    public function test_partition_preconcept() {
        var n = 0;

        var a = [];
        for (x in new IterArmy<Float>([ 
            new IterRange( 0,10, 1), 
            new IterRange(10,20, 1), 
            new IterRange(20,30, 1), 
            new IterRange(30,40, 1), 
            new IterRange(40,50, 1), 
        ])) a.push(x);

        assertEquals ( a[0]     , 0  ) ;
        assertEquals ( a[1]     , 10 ) ;
        assertEquals ( a[2]     , 20 ) ;
        assertEquals ( a[3]     , 30 ) ;
        assertEquals ( a[4]     , 40 ) ;
        assertEquals ( a[5]     , 1  ) ;
        assertEquals ( a[6]     , 11 ) ;
        assertEquals ( a[7]     , 21 ) ;
        assertEquals ( a[8]     , 31 ) ;
        assertEquals ( a[9]     , 41 ) ;
        assertEquals ( a[10]    , 2  ) ;
        assertEquals ( a[11]    , 12 ) ;
        assertEquals ( a[12]    , 22 ) ;
        assertEquals ( a[13]    , 32 ) ;
        assertEquals ( a[14]    , 42 ) ;
        assertEquals ( a[15]    , 3  ) ;
        assertEquals ( a[16]    , 13 ) ;
        assertEquals ( a[17]    , 23 ) ;
        assertEquals ( a[18]    , 33 ) ;
        assertEquals ( a[19]    , 43 ) ;
        assertEquals ( a[20]    , 4  ) ;
        assertEquals ( a[21]    , 14 ) ;
        assertEquals ( a[22]    , 24 ) ;
        assertEquals ( a[23]    , 34 ) ;
        assertEquals ( a[24]    , 44 ) ;
        assertEquals ( a[25]    , 5  ) ;
        assertEquals ( a[26]    , 15 ) ;
        assertEquals ( a[27]    , 25 ) ;
        assertEquals ( a[28]    , 35 ) ;
        assertEquals ( a[29]    , 45 ) ;
        assertEquals ( a[30]    , 6  ) ;
        assertEquals ( a[31]    , 16 ) ;
        assertEquals ( a[32]    , 26 ) ;
        assertEquals ( a[33]    , 36 ) ;
        assertEquals ( a[34]    , 46 ) ;
        assertEquals ( a[35]    , 7  ) ;
        assertEquals ( a[36]    , 17 ) ;
        assertEquals ( a[37]    , 27 ) ;
        assertEquals ( a[38]    , 37 ) ;
        assertEquals ( a[39]    , 47 ) ;
        assertEquals ( a[40]    , 8  ) ;
        assertEquals ( a[41]    , 18 ) ;
        assertEquals ( a[42]    , 28 ) ;
        assertEquals ( a[43]    , 38 ) ;
        assertEquals ( a[44]    , 48 ) ;
        assertEquals ( a[45]    , 9  ) ;
        assertEquals ( a[46]    , 19 ) ;
        assertEquals ( a[47]    , 29 ) ;
        assertEquals ( a[48]    , 39 ) ;
        assertEquals ( a[49]    , 49 ) ;
        assertEquals ( a.length , 50 ) ;
    }

} 
