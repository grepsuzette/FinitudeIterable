/**
 * As of Wed Mar 16 19:34:06 CST 2016
 *
 * Results:
 * --------
 *
BenchAnonymousVsClass.hx:43: 78
Chrono.hx:100: @NoChronoName@ noName: 0ms
Chrono.hx:100: @NoChronoName@ Haxe iter ...: 751ms
Chrono.hx:100: @NoChronoName@ Range w/ variable: 780ms
Chrono.hx:100: @NoChronoName@ IRU: 772ms
Chrono.hx:100: @NoChronoName@ tink_lang for (i += 1 in 0...times): 915ms
Chrono.hx:100: @NoChronoName@ anonrange: 1938ms
BenchAnonymousVsClass.hx:60: ---- with duplication dup(2) ------
Chrono.hx:100: @NoChronoName@ Rrrange class as simple as anonrange: 1062ms
Chrono.hx:100: @NoChronoName@ flatloop dup (simulated) by for (i in r) { op(i); op(i); }: 1760ms
Chrono.hx:100: @NoChronoName@ flatloop dup (simulated) by for () for (0...2) op(i): 2195ms
Chrono.hx:100: @NoChronoName@ Range w/ dup: 6342ms
Chrono.hx:100: @NoChronoName@ IRU w/ dup: 5987ms
Chrono.hx:100: @NoChronoName@ IRU w/ dup w/ iterators declared beforehand: 6012ms
Chrono.hx:100: @NoChronoName@ anonrange w/ dup: 6521ms
Chrono.hx:100: @NoChronoName@ Rrrange class as simple as anonrange w/ dup: 6991ms
Chrono.hx:100: @NoChronoName@ Manually inlined dup/range: 4722ms
Chrono.hx:100: @NoChronoName@ Manually inlined dup/range, no indirection: 3390ms
 *
 * Conclusion
 * ----------
 * range() has acceptable speed. However must find a way to force inline
 *         whenever combined with other FinitudeIterables.
 * dup() is pretty slow, and will be hard to optimize keeping the
 *         iterator style and without macro. It should be used sparingly.
 */
import IterRange.range as range;
import IterRange.rangeG as rangeG;
import Chrono;

using IterDup;
using Lambda;
using tink.CoreApi;

class Rrrange {
    var ab:Int;
    var ad:Int;
    public inline function new(from:Int, to:Int) { ab = from; ad = to; }
    public inline function next() {
        var ret = ab;
        ab+=1;
        return ret;
    }
    public inline function hasNext() return ab - ad != 0;
    public inline function iterator() return this;
}

@:tink class BenchAnonymousVsClass {

    public static function anonrange(from:Int, to:Int) {
        var it = {
            next: function() { var ret = from; from +=1; return ret; },
            hasNext: function() { return from - to != 0; },
            iterator: null
        };
        Reflect.setField(it, 'iterator', function() { return it; });
        return it;
    }

    public static inline function myInline(i:Int) return i+i;
    public static inline function myAlias(i:Int) return myInline(i);

    public static function someop(i:Int):Int return i + i * 4 - i * 529;

    public static function main() {
        var times:Int = cast 3e6;
        
        var i = 35;
        trace(myAlias(4 + i));

        var c = new Chrono();         
        c.start();
        c.ss("Haxe iter ...");
        for (i in 0... times) someop(i);
        c.ss("Range w/ variable");
        for (i in range(0, times)) someop(i);
        c.ss("IRU");
        for (i in new IterRange.IRU(0, times)) someop(i);
        c.ss("tink_lang for (i += 1 in 0...times)");
        for (i += 1 in 0...times) someop(i);
        c.ss("anonrange");
        for (i in anonrange(0, times)) someop(i);
        c.ss("Rrrange class as simple as anonrange");
        for (i in new Rrrange(0, times)) someop(i);

        trace("---- with duplication dup(2) ------");

        c.ss("flatloop dup (simulated) by for (i in r) { op(i); op(i); }");
        var r = new IterRange.IRU(0, times);
        for (i in r) { someop(i); someop(i); }
        c.ss("flatloop dup (simulated) by for () for (0...2) op(i)");
        var r = new IterRange.IRU(0, times);
        for (i in r) { for (k in 0...1) someop(i); }
        c.ss("Range w/ dup");
        for (i in range(0, times).dup()) someop(i);
        c.ss("IRU w/ dup");
        for (i in new IterDup(new IterRange.IRU(0, times))) someop(i);
        c.ss("IRU w/ dup w/ iterators declared beforehand");
        var r = new IterRange.IRU(0, times);
        var d = new IterDup(r);
        for (i in d) someop(i);
        c.ss("anonrange w/ dup");
        for (i in anonrange(0, times).dup()) someop(i);
        c.ss("Rrrange class as simple as anonrange w/ dup");
        for (i in new Rrrange(0, times).dup()) someop(i);

        var itdup = new FakeDup();
        itdup.a = new FakeRange(0, times);
        itdup.n = 2;
        itdup.c = 0;
        itdup.t = itdup.a.ab;
        itdup.it = itdup.a;
        c.ss("Manually inlined dup/range");

        while ( itdup.n > 0 && (itdup.c < itdup.n || itdup.it.n < itdup.it.ad)) {
            var i;
            if (itdup.c++ < itdup.n) i = itdup.t;
            else {
                itdup.c = 1;
                i = itdup.it.n++;
            }
            someop(i);
        }

        c.ss("Manually inlined dup/range, no indirection");

        var ab = 0;
        var n = 0;
        var ad = times;
        var itdup_a = new FakeRange(0, times);
        var itdup_n = 2;
        var itdup_c = 0;
        var itdup_t = ab;
        var itdup_it = itdup.a;
        while ( itdup_n > 0 && (itdup_c < itdup_n || n < ad)) {
            var i;
            if (itdup_c++ < itdup_n) i = itdup_t;
            else {
                itdup_c = 1;
                i = n++;
            }
            someop(i);
        }

        c.stop();
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

