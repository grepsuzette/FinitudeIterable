import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using IterChain;
using IterLoop;
using IterDual;
using Lambda;
import IterRange.range as range;
import IterRange.rangeDown as rangeDown;
import IterDual.dual as dual;
import IterDual.dualLoop as dualLoop;

class TestIterChain extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterChain());
        runner.run();
    }

    public function test_as_array() {
        var sum = 0;
        for (i in new IterChain([
            new IterRange(0   , 3   , 1)  ,
            new IterRange(-10 , -13 , -1) ,
            new IterRange(3   , 6   , 1)
        ])) sum += i;
        assertEquals(sum, -18);
    }

    public function test_as_array2() {
        assertEquals(
            new IterChain([ 
                range(0,   3  ),
                rangeDown(-10, -13),
                range(3,   6  ),
            ]).fold( function(x, i) return i += x, 0 ),
            -18
        ); 
    }

    public function test_as_array3() {
        assertEquals(
            [ range(0,   3  ),
              rangeDown(-10, -13),
              range(3,   6  ),
            ].iterChain()
             .fold( function(x, i) return i += x, 0 ),
            -18
        ); 

    }

    public function test_various() {
        var a = ["peach", "cherry"];
        var l = ["friday", "saturday"];
        
        var test = dual( [a, l].iterChain(), range(0, 2), Loop).array();
        assertEquals(test.length, 4);
        assertEquals(test[0]._1, "peach");
        assertEquals(test[1]._1, "cherry");
        assertEquals(test[2]._1, "friday");
        assertEquals(test[3]._1, "saturday");
        assertEquals(test[0]._2, 0);
        assertEquals(test[1]._2, 1);
        assertEquals(test[2]._2, 0);
        assertEquals(test[3]._2, 1);
    }
}

