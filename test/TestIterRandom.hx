import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using IterRandom;
using Lambda;

class TestIterRandom extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterRandom());
        runner.run();
    }

    public function test_some_very_stupid_example() {
        var a = [ for (i in 0...100) i * 1000 + i/2 - 7 ];
        var sum = 0.;
        var b = [];
        for (x in a.iterRandom()) {
            sum += x;
            b.push(x);
        }
        // print(sum);
        assertEquals( a.length, b.length );
    }
    
    public function valuesAreAllUnique<T>(a:Array<T>):Bool {
        for (i in 0...a.length-1)
            for (j in i+1...a.length)
                if (a[i] == a[j]) return false;
        return true;
    }

    public function test_unique_values() {
        assertTrue(valuesAreAllUnique([ for (i in 0...1000) i ].iterRandom().array()));
    }
    
    public function test_infinite() {
        var sum = 0;
        var i = 0;
        for (x in [1,2,3].iterRandom(true)) {
            sum += x;
            if (i++ > 100) break;
        }
        assertTrue(sum > 100);
    }
}
