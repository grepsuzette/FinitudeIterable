/*
As of Wed Mar 16 16:41:32 CST 2016

Results for 1 million iterations (resulting in 2 million):
----------------------------------------------------------
Chrono.hx:100: @_@ direct : 619ms
Chrono.hx:100: @_@ new IterReverse(a): 415ms
Chrono.hx:100: @_@ a.iterReverse(): 450ms

Bench
------------
Method used for "direct" was:
    for (i in -a.length+1...1) {
        var x = a[-i];
        x = (x + 235) * x;
    }
VS for (x in new IterReverse(a)) x = (x + 235) * x;

The iterator appears faster, if so that's pretty good news.
Why would that be faster?
 Inlined methods for IterReverse are 
    hasNext() return i > 0;
    next() return a[--i];     <- We skip the index search here

*/

import Chrono;
import IterRange;
import IterRange.range as range;
using Lambda;
using IterReverse;

/**
 * This benchmark aim at determining
 * how much overhead is brought with the IterReverse.
 */
class BenchReverse {
    
    public static function main() {
        test(1000 * 1000);
    }

    public static function test(times:Int) {
        var ch = new Chrono("_");
        var a : Array<Int> = [ for (i in 0...times) i ];

        ch.ss("direct ");
        for (i in -a.length+1...1) {
            var x = a[-i];
            x = (x + 235) * x;
            // trace(x);
        }

        ch.ss("new IterReverse(a)");
        for (x in new IterReverse(a)) {
            x = (x + 235) * x;
            // trace(x);
        }

        ch.ss("a.iterReverse()");
        for (x in a.iterReverse()) {
            x = (x + 235) * x;
            // trace(x);
        }

        ch.stop();
    }
}



