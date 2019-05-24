/*
As of Wed Mar 16 16:41:32 CST 2016

Results for 1 million iterations (resulting in 2 million):
----------------------------------------------------------
Chrono.hx:100: @_@ direct : 809ms
Chrono.hx:100: @_@ new IterRandom(a): 927ms

Bench
------------
Pretty close results
*/

import Chrono;
import IterRange;
import IterRange.range as range;
using Lambda;
using IterRandom;

/**
 * This benchmark aim at determining
 * how much overhead is brought with the IterRandom
 */
class BenchRandom {
    
    public static function main() {
        test(100 * 1000);
    }

    public static function test(times:Int) {
        var ch = new Chrono("_");
        var a : Array<Int> = [ for (i in 0...times) i ];

        ch.ss("direct ");
        var b = a.copy();
        b.sort( function(x,y) return Math.random() < .5 ? 1 : -1 );      
        for (x in b) x = (x + 235) * x;
            // trace(x);

        ch.ss("new IterRandom(a)");
        for (x in new IterRandom(a)) x = (x + 235) * x;
            // trace(i);

        ch.stop();
    }
}


