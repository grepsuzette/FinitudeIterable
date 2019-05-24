import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import IterRange.range as range;
import IterRange.rangeStep as rangeStep;
import IterRange.rangeDown as rangeDown;
import IterRange.rangeStepDown as rangeStepDown;
import IterRange.rangeG as rangeG;
using IterRange;
using Lambda;


class TestIterRange extends TestCase {

    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterRange());
        runner.run();
    }


    public function test_range() {
        var a = [];
        for (i in rangeDown(2, -2)) {
            a.push(i);
        }
        assertEquals(a[0], 2);
        assertEquals(a[1], 1);
        assertEquals(a[2], 0);
        assertEquals(a[3], -1);
        assertEquals(a.length, 4);

        var a = range(0,4).array();
        assertEquals(a[0], 0);
        assertEquals(a[1], 1);
        assertEquals(a[2], 2);
        assertEquals(a[3], 3);
        assertEquals(a.length, 4);
    }

    public function test_reverse_arg() {
        var a = [];
        var b = [];

        for(i in new IterRange(9, -1, 1)) a.push(i);
        for(i in new IterRange(0, 10, 1, true).array() ) b.push(i);
        assertEquals(a.length, b.length);
        for (i in 0...a.length) assertEquals(a[i], b[i]);

    }


    public function test_1() {
        var a = new IterRange<Float>(2, -2, -.5).array();
        assertEquals(a[0], 2);
        assertEquals(a[1], 1.5);
        assertEquals(a[2], 1);
        assertEquals(a[3], .5);
        assertEquals(a[4], 0);
        assertEquals(a[5], -.5);
        assertEquals(a[6], -1);
        assertEquals(a[7], -1.5);
        assertEquals(a.length, 8);
    }

    public function test_incompleteEndings() {
        var a = range(0, 5).array();
        assertEquals(a[0], 0    );
        assertEquals(a[1], 1    );
        assertEquals(a[2], 2    );
        assertEquals(a[3], 3    );
        assertEquals(a[4], 4    );
        assertEquals(a.length, 5);
    }


    public function test_incompleteEndings_othersign() {
        var a = rangeG(0, 5, -1).array();
        assertEquals(a[0], 0    );
        assertEquals(a[1], 1    );
        assertEquals(a[2], 2    );
        assertEquals(a[3], 3    );
        assertEquals(a[4], 4    );
        assertEquals(a.length, 5);
    }

    public function test_incompleteEndings2() {
        var b = rangeG(9., 10.2, 0.5).array();
        assertEquals(b[0], 9    );
        assertEquals(b[1], 9.5  );
        assertEquals(b[2], 10   );
        assertEquals(b.length, 3);
        
        var b = rangeG(9., 10.2, 0.5).array();
        assertEquals(b[0], 9    );
        assertEquals(b[1], 9.5  );
        assertEquals(b[2], 10   );
        assertEquals(b.length, 3);
    }
        
     public function test_incompleteEndings2_othersign() {
         var b = rangeG(9., 10.2, -0.5).array();
         assertEquals(b[0], 9.   );
         assertEquals(b[1], 9.5  );
         assertEquals(b[2], 10.  );
         assertEquals(b.length, 3);
    
         var b = rangeG(9., 10.2, -0.5).array();
         assertEquals(b[0], 9.   );
         assertEquals(b[1], 9.5  );
         assertEquals(b[2], 10.  );
         assertEquals(b.length, 3);
     }

    public function test_incompleteEndings3() {
        var c = rangeStepDown(2, -2, -3).array();
        assertEquals(c[0], 2    );
        assertEquals(c[1], -1   );
        assertEquals(c.length, 2);
    }

    public function test_incompleteEndings3_othersign() {
        var c = rangeStepDown(2, -2, -3).array();
        assertEquals(c[0], 2    );
        assertEquals(c[1], -1   );
        assertEquals(c.length, 2);

        var c = rangeG(2, -2, -3).array();
        assertEquals(c[0], 2    );
        assertEquals(c[1], -1   );
        assertEquals(c.length, 2);
    }

    public function test_incompleteEndings4() {
        var d = rangeG(2, 2, 1).array();
        assertEquals(d.length, 0);
        
        var d = rangeStep (2, 2, 1).array();
        assertEquals(d.length, 0);
    }

    public function test_incompleteEndings4_othersign() {
        var d = rangeStepDown(2, 2, -1).array();
        assertEquals(d.length, 0);

        var d = rangeDown(2, 2).array();
        assertEquals(d.length, 0);

        var d = rangeG(2, 2, -1).array();
        assertEquals(d.length, 0);

        var d = rangeG(2, 2).array();
        assertEquals(d.length, 0);

        var d = rangeG(2, 2, -1, true).array();
        assertEquals(d.length, 0);
    }

    // public function test_for_meet() {
    //     var a = range(0, 10, 10/2).array();   // 2 elements
    //     var a = range(0, 11, 11/2).array();   // 2 elements
    //     // assertEquals(a.length, 3);

    //     for (n in 1...30) {
    //         print ("\n:" + n + ":\n");
    //         for (len in 1...200) {
    //             print ('/$len');
    //             assertEquals(new IterRange(0, len, len/(n <= len? 1 :n)).array().length, n);
    //         }
    //     }
    // }

    // IterRange must be consistent with Haxe `...` iterator 
    public function test_compare_defaultIter_with_iterStep() {
        var a = [ for (i in 0...5) i ];
        var b = range(0, 5).array();
        var c = rangeG(5, 0, 1).array();
        assertEquals(a.length, b.length);
        assertEquals(a.length, c.length);
        for (i in 0...a.length) assertEquals(a[i], cast b[i]);
        for (i in 0...a.length) assertEquals(c[a.length - i - 1] - 1, a[i]);
    }

    // IterRange must be consistent with Haxe `...` iterator 
    public function test_compare_defaultIter_with_iterStep_fromXtoX() {
        var a = [ for (i in 0...0) i ];
        var b = rangeG(0, 0, 1).array();
        var c = rangeG(0, 0, 1).array();
        assertEquals(a.length, b.length);
        assertEquals(a.length, c.length);
        for (i in 0...a.length) assertEquals(a[i], cast b[i]);
        for (i in 0...a.length) assertEquals(c[a.length - i - 1] - 1, a[i]);
    }

    // IterRange must be consistent with Haxe `...` iterator 
    public function test_compare_defaultIter_with_iterStep_fromXtoX_plus1() { var a = [ for (i in 0...1) i ];
        var b = range(0, 1).array();
        var c = rangeDown(1, 0).array();
        assertEquals(a.length, b.length);
        assertEquals(a.length, c.length);
        for (i in 0...a.length) assertEquals(a[i], cast b[i]);
        for (i in 0...a.length) assertEquals(c[a.length - i - 1] - 1, cast a[i]);
    }

    public function test_rangeDown() {
        var a = rangeDown(-10, -13).array();
        assertEquals(a[0], -10);
        assertEquals(a[1], -11);
        assertEquals(a[2], -12);
    } 
} 


