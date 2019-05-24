/*
As of Wed Mar 16 16:26:23 CST 2016

Results for 1 million iterations (resulting in 2 million):
----------------------------------------------------------

BenchLoopVsInlined.hx:78: ------------- pingpong ---------------
BenchLoopVsInlined.hx:79: We will run 1000 times pingpong over an iterable of 1000 elements
Chrono.hx:100: @_@ direct... We can just run $times * $count * 2 but obviously it's not the same: 1467ms
Chrono.hx:100: @_@ IterLoop.pingpong(new IRU(0, count), times): 4292ms
Chrono.hx:100: @_@ range(0, count).pingpong(times): 4149ms
Chrono.hx:100: @_@ new IterLoop(new IRU(0, count), times*2) to compare: 3454ms
BenchLoopVsInlined.hx:104: ------------- sustain ---------------
BenchLoopVsInlined.hx:105: We will run 100 times sustain over an iterable of 10000 elements
Chrono.hx:100: @_@ direct... We can just run $times + $count but obviously it's not the same: 8ms
Chrono.hx:100: @_@ range(0, count).sustain(times): 16ms
BenchLoopVsInlined.hx:121: ------------- trill ---------------
BenchLoopVsInlined.hx:122: We will run 100 times trill over an iterable of 10000 elements
Chrono.hx:100: @_@ direct... We can just run $times + $count but obviously it's not the same: 7ms
Chrono.hx:100: @_@ range(0, count).trill(times): 16ms
BenchLoopVsInlined.hx:140: ------------- LoopLastN ---------------
BenchLoopVsInlined.hx:141: We will run 10 times loopLastN where N is 10 over an iterable of 10000 elements
Chrono.hx:100: @_@ direct... We can just run $times + ($count*$repeat) but obviously it's not the same: 7ms
Chrono.hx:100: @_@ range(0, count).loopLastN(times): 32ms

Conclusions:
------------
For loop(), pingpong() and loopLastN() it's the same as for dup(), 
better to make an outer loop or slice an array when possible.
Optimization was attempted, but some iterators using IterLoop 
such as IterArmy seem to require current implementation.

trill() and sustain() are okay.

*/

import Chrono;
import IterRange;
import IterRange.range as range;
import IterLoop.pingpong as pingpong;
import IterLoopLastN;
using IterSustain;
using IterTrill;
using Lambda;
using IterLoop;

/**
 * This benchmark aim at determining
 * how much overhead is brought with the IterLoop
 */

class BenchLoopVsInlined {
    
    // Some short test
    public static function doSomethingWith(i:Int) 
        return i + 442 - i /2452 + i % 3453 * 23534 - 2345 * i / (i+2445);

    public static function main() {
        // test(1000, 1000);
        // test(100 * 1000, 10);
        // test(10, 100 * 1000);
    
        testPingpong(1000, 1000);
        testSustain(10000, 100);
        testTrill(10000, 100);
        testLoopLastN(10000, 10, 10);
    }

    public static function test(times:Int, count:Int) {
        trace('We will run $times loops over an iterable of $count elements');
        var ch = new Chrono("_");
        var myArray = range(0, count).array();

        ch.ss("direct (external for() to simulate a loop)");            
        for (k in 0...times) 
            for (e in myArray)
                doSomethingWith(e);

        ch.ss("new IterLoop(new IRU(0, count), times)");
        for (i in new IterLoop(new IRU(0, count), times))
            doSomethingWith(i);

        ch.ss("new IterLoop(myArray, times)");
        for (i in new IterLoop(myArray, times))
            doSomethingWith(i);

        ch.ss("range(0, count).loop(times)");
        for (i in range(0, count).loop(times))
            doSomethingWith(i);

        ch.ss("range(0, count).loop(times)");
        for (i in myArray.loop(times))
            doSomethingWith(i);


        ch.stop();
    }

    public static function testPingpong(count:Int, times:Int) {
        trace("------------- pingpong ---------------");
        trace('We will run $times times pingpong over an iterable of $count elements');
        var ch = new Chrono("_");
        var myArray = range(0, count).array();

        ch.ss("direct... We can just run $times * $count * 2 but obviously it's not the same");            
        for (k in 0...times * 2) 
            for (i in 0...count)
                doSomethingWith(i);

        ch.ss("IterLoop.pingpong(new IRU(0, count), times)");
        for (i in IterLoop.pingpong(new IRU(0, count), times))
            doSomethingWith(i);

        ch.ss("range(0, count).pingpong(times)");
        for (i in range(0, count).pingpong(times))
            doSomethingWith(i);

        ch.ss("new IterLoop(new IRU(0, count), times*2) to compare");
        for (i in new IterLoop(new IRU(0, count), times + times))
            doSomethingWith(i);

        ch.stop();
    }

    public static function testSustain(count:Int, times:Int) {
        trace("------------- sustain ---------------");
        trace('We will run $times times sustain over an iterable of $count elements');
        var ch = new Chrono("_");
        var myArray = range(0, count).array();

        ch.ss("direct... We can just run $times + $count but obviously it's not the same");            
        for (k in 0...times + count) 
            doSomethingWith(k);

        ch.ss("range(0, count).sustain(times)");
        for (i in range(0, count).sustain(times))
            doSomethingWith(i);

        ch.stop();
    }

    public static function testTrill(count:Int, times:Int) {
        trace("------------- trill ---------------");
        trace('We will run $times times trill over an iterable of $count elements');
        var ch = new Chrono("_");
        var myArray = range(0, count).array();

        ch.ss("direct... We can just run $times + $count but obviously it's not the same");            
        for (i in 0...times + count) 
                doSomethingWith(i);

        ch.ss("range(0, count).trill(times)");
        for (i in range(0, count).trill(times))
            doSomethingWith(i);


        ch.stop();
    
    }

    public static function testLoopLastN(count:Int, times:Int, repeat:Int) {
        trace("------------- LoopLastN ---------------");
        trace('We will run $times times loopLastN where N is $repeat over an iterable of $count elements');
        var ch = new Chrono("_");
        var myArray = range(0, count).array();

        ch.ss("direct... We can just run $times + ($count*$repeat) but obviously it's not the same");            
        for (i in 0...count + (times * repeat)) 
                doSomethingWith(i);

        ch.ss("range(0, count).loopLastN(times)");
        for (i in range(0, count).loopLastN(times, repeat))
            doSomethingWith(i);


        ch.stop();
    

    }
}


