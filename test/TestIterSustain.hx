import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using IterSustain;

class TestIterSustain extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterSustain());
        runner.run();
    }

    public function test_infinite() {
        var i = 0;
        var a = [];
        for (s in ["fish", "monkey", "human"].sustain()) {
            a.push(s);
            if (++i >= 10) break;
        }
        assertEquals( a.length, 10 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "human" );
        assertEquals( a[3], "human" );
        assertEquals( a[4], "human" );
        assertEquals( a[5], "human" );
        assertEquals( a[6], "human" );
        assertEquals( a[7], "human" );
        assertEquals( a[8], "human" );
        assertEquals( a[9], "human" );
    }

    public function test_finite() {
        var a = [];
        for (s in ["fish", "monkey", "boing"].sustain(1)) {
            a.push(s);
        }
        assertEquals( a.length, 4 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "boing" );
        assertEquals( a[3], "boing" );
    }
}
