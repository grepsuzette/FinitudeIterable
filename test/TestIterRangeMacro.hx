import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import IterRangeMacro.rangeM as range;
import IterRangeMacro;
using Lambda;


class TestIterRangeMacro extends TestCase {

    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterRangeMacro());
        runner.run();
    }


    public function test_range() {
        var a = [];
        for (i in range(2, -2)) {
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

        for(i in range(9, -1, 1)) a.push(i);
        for(i in range(0, 10, 1, true).array() ) b.push(i);
        assertEquals(a.length, b.length);
        for (i in 0...a.length) assertEquals(a[i], b[i]);
    }


    public function test_1() {
        var a = range(2, -2, -.5).array();
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
        var a = range(0, 5, 1).array();
        assertEquals(a[0], 0    );
        assertEquals(a[1], 1    );
        assertEquals(a[2], 2    );
        assertEquals(a[3], 3    );
        assertEquals(a[4], 4    );
        assertEquals(a.length, 5);
    }


    public function test_incompleteEndings_othersign() {
        var a = range(0, 5, -1).array();
        assertEquals(a[0], 0    );
        assertEquals(a[1], 1    );
        assertEquals(a[2], 2    );
        assertEquals(a[3], 3    );
        assertEquals(a[4], 4    );
        assertEquals(a.length, 5);
    }

    public function test_incompleteEndings2() {
        var b = new IterRange<Float>(9, 10.2, 0.5).array();
        assertEquals(b[0], 9    );
        assertEquals(b[1], 9.5  );
        assertEquals(b[2], 10   );
        assertEquals(b.length, 3);
        
        var b = range(9, 10.2, 0.5).array();
        assertEquals(b[0], 9    );
        assertEquals(b[1], 9.5  );
        assertEquals(b[2], 10   );
        assertEquals(b.length, 3);
    }
        
    public function test_incompleteEndings2_othersign() {
        var b = new IterRange(9., 10.2, -0.5).array();
        assertEquals(b[0], 9.   );
        assertEquals(b[1], 9.5  );
        assertEquals(b[2], 10.  );
        assertEquals(b.length, 3);

        var b = range(9., 10.2, -0.5).array();
        assertEquals(b[0], 9.   );
        assertEquals(b[1], 9.5  );
        assertEquals(b[2], 10.  );
        assertEquals(b.length, 3);
    }

    public function test_incompleteEndings3() {
        var c = new IterRange(2, -2, 3).array();
        assertEquals(c[0], 2    );
        assertEquals(c[1], -1   );
        assertEquals(c.length, 2);

        var c = range(2, -2, 3).array();
        assertEquals(c[0], 2    );
        assertEquals(c[1], -1   );
        assertEquals(c.length, 2);
    }

    public function test_incompleteEndings3_othersign() {
        var c = new IterRange(2, -2, -3).array();
        assertEquals(c[0], 2    );
        assertEquals(c[1], -1   );
        assertEquals(c.length, 2);

        var c = range(2, -2, -3).array();
        assertEquals(c[0], 2    );
        assertEquals(c[1], -1   );
        assertEquals(c.length, 2);
    }

    public function test_incompleteEndings4() {
        var d = new IterRange(2, 2, 1).array();
        assertEquals(d.length, 0);
        
        var d = range(2, 2, 1).array();
        assertEquals(d.length, 0);
    }

    public function test_incompleteEndings4_othersign() {
        var d = new IterRange(2, 2, -1).array();
        assertEquals(d.length, 0);

        var d = range(2, 2, -1).array();
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
        var b = range(0, 5, 1).array();
        var c = range(5, 0, 1).array();
        assertEquals(a.length, b.length);
        assertEquals(a.length, c.length);
        for (i in 0...a.length) assertEquals(a[i], cast b[i]);
        for (i in 0...a.length) assertEquals(c[a.length - i - 1] - 1, a[i]);
    }

    // IterRange must be consistent with Haxe `...` iterator 
    public function test_compare_defaultIter_with_iterStep_fromXtoX() {
        var a = [ for (i in 0...0) i ];
        var b = new IterRange(0, 0, 1).array();
        var c = new IterRange(0, 0, 1).array();
        assertEquals(a.length, b.length);
        assertEquals(a.length, c.length);
        for (i in 0...a.length) assertEquals(a[i], cast b[i]);
        for (i in 0...a.length) assertEquals(c[a.length - i - 1] - 1, a[i]);
    }

    // IterRange must be consistent with Haxe `...` iterator 
    public function test_compare_defaultIter_with_iterStep_fromXtoX_plus1() {
        var a = [ for (i in 0...1) i ];
        var b = range(0, 1, 1).array();
        var c = range(1, 0, 1).array();
        assertEquals(a.length, b.length);
        assertEquals(a.length, c.length);
        for (i in 0...a.length) assertEquals(a[i], cast b[i]);
        for (i in 0...a.length) assertEquals(c[a.length - i - 1] - 1, cast a[i]);
    }

    // ----------------------------------------------
    // private classes tests
    public function test_IterRangeIntUp() {
        var a = [];
        for (i in 0...5) a.push(i);
        assertEquals(a.length, 5);

        var a = [];
        for (i in new IRSU(0, 5, 1)) a.push(i);
        var i = 0;
        assertEquals(a.length, 5);
        assertEquals(a[i++], 0);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 4);

        var a = [];
        for (i in new IRSU(0, 5, 2)) a.push(i);
        var i = 0;
        assertEquals(a.length, 3);
        assertEquals(a[i++], 0);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 4);

        var a = [];
        for (i in new IRU(0, 5)) a.push(i);
        var i = 0;
        assertEquals(a.length, 5);
        assertEquals(a[i++], 0);
        assertEquals(a[i++], 1);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 4);

        
        var a = []; 
        for (i in new IRSD(5, 0, -2)) a.push(i);
        var i = 0;
        assertEquals(a.length, 3);
        assertEquals(a[i++], 5);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 1);

        var a = []; 
        for (i in new IRSD(2, -2, -2)) a.push(i);
        var i = 0;
        assertEquals(a.length, 2);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 0);

        var a = [];
        for (i in new IRD(5, 0)) a.push(i);
        var i = 0;
        assertEquals(a.length, 5);
        assertEquals(a[i++], 5);
        assertEquals(a[i++], 4);
        assertEquals(a[i++], 3);
        assertEquals(a[i++], 2);
        assertEquals(a[i++], 1);

    }

    public function test_macro_with_vars_instead_of_const() {
        var from = 5.;
        var to = 7.5;
        var step = .5;
        var a = [];
        for (i in range(from, to, step)) a.push(i);
        assertEquals(a.length, 5);
        var i = 0;
        assertEquals(a[i++], 5);
        assertEquals(a[i++], 5.5);
        assertEquals(a[i++], 6);
        assertEquals(a[i++], 6.5);
        assertEquals(a[i++], 7);
    }
    
} 


