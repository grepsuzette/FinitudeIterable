/*
As of Wed Mar 16 15:07:06 CST 2016

Results for 1 million iterations (resulting in 2 million):
----------------------------------------------------------
- direct (not even function call for op): 1094ms
- direct (with same function call for op, doubled): 1220ms
- Fully manually Inlined Dup(Range)): 2332ms
- Dup(Range): 2783ms
- copying array of 1million so its 2million, then iter: 2575ms
- copying array of 1million to a 2million *list*, then iter; 2538ms

Conclusions:
------------
In cases when nothing follows the dup() of course it is 
better not to write the dup() and duplicate the line/block 
directly.
Otherwise, duplicating an array as opposed to just using 
range+dup() is to small for us to bother (besides, dup()
can handle infinite iterables just fine as it is, and is
interruptible).
The fully manually inlined test also proves using an iterator
we can't expect much compared to a direct approach. Therefore
dup() should be used sparingly.
*/

import Chrono;
import IterRange;
import IterRange.range as range;
using Lambda;
using IterDup;

/**
 * This benchmark aim is to determine 
 * whether we would really benefit of 
 * having a "deep inline" in those cases 
 * when we have several iterators.
 */

class BenchDupRange {
    
    // Some short test
    public static function doSomethingWith(i:Int) 
        return i + 442 - i /2452 + i % 3453 * 23534 - 2345 * i / (i+2445);

    // 3 tests here: fullyinlined dup(range()) VS dup(range()) VS flatloop
    public static function main() {
        var times = 1000 * 1000;
        var ch = new Chrono("_");
        var myArray = range(0, times).array();

        var itdup = new FakeDup();
        itdup.a = new FakeRange(0, times);
        itdup.n = 2;
        itdup.c = 0;
        itdup.t = itdup.a.ab;
        itdup.it = itdup.a;

        ch.ss("direct (not even function call for op)");            
        for (i in 0...times) {
            i + 442 - i /2452 + i % 3453 * 23534 - 2345 * i / (i+2445);
            i + 442 - i /2452 + i % 3453 * 23534 - 2345 * i / (i+2445);
        }

        ch.ss("direct (with same function call for op, doubled)");            
        for (i in 0...times) {
            doSomethingWith(i);
            doSomethingWith(i);
        }

        ch.ss("Fully manually Inlined Dup(Range))"); 
        while ( itdup.n > 0 && (itdup.c < itdup.n || itdup.it.n < itdup.it.ad)) {
            var i;
            if (itdup.c++ < itdup.n) i = itdup.t;
            else {
                itdup.c = 1;
                i = itdup.it.n++;
            }
            doSomethingWith(i);
        }

        ch.ss("new IterDup(new IRU(0, times))");
        for (i in new IterDup(new IRU(0, times)))
            doSomethingWith(i);

        ch.ss("new IterDup(range(0, times))");
        for (i in new IterDup(range(0, times)))
            doSomethingWith(i);

        ch.ss("range(0, times).dup()");
        for (i in range(0, times).dup())
            doSomethingWith(i);

        ch.ss("copying array of 1million so its 2million, then iter");
        var eightythousand = [];
        for (i in myArray) {
            eightythousand.push(i);
            eightythousand.push(i);
        }
        for (i in myArray) 
            doSomethingWith(i);

        ch.ss("copying array of 1million to a 2million *list*, then iter");
        var eightythousand = new List();
        for (i in myArray) {
            eightythousand.add(i);
            eightythousand.add(i);
        }
        for (i in myArray) 
            doSomethingWith(i);

        ch.stop();
    }
}

// Those 2 classes are similar to IterDup and IterRange.IRU except the code
// is manually inlined in BenchDupRangeVsInlined.
class FakeDup {
    public var a               : FakeRange;      
    public var n               : Int;            
    public var it              : FakeRange;      
    public var c               : Int;            
    public var t               : Int;
    public function new() {}
}

class FakeRange {
    public var ab:Int;
    public var ad:Int;
    public var n:Int;
    public function new(from:Int, to:Int) { ab = n = from; ad = to; }
}

