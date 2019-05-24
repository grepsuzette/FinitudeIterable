import haxe.unit.TestRunner;
import haxe.unit.TestCase;

using IterTrill;

class TestIterTrill extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterTrill());
        runner.run();
    }

    public function test_infinite() {
        var i = 0;
        var a = [];
        for (s in ["fish", "monkey", "human"].trill()) {
            a.push(s);
            if (++i >= 10) break;
        }
        assertEquals( a.length, 10 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "human" );
        assertEquals( a[3], "monkey" );
        assertEquals( a[4], "human" );
        assertEquals( a[5], "monkey" );
        assertEquals( a[6], "human" );
        assertEquals( a[7], "monkey" );
        assertEquals( a[8], "human" );
        assertEquals( a[9], "monkey" );
    }

    public function test_finite() {
        var a = [];
        for (s in ["fish", "monkey", "boing"].trill(1)) {
            a.push(s);
        }
        assertEquals( a.length, 5 );
        assertEquals( a[0], "fish" );
        assertEquals( a[1], "monkey" );
        assertEquals( a[2], "boing" );
        assertEquals( a[3], "monkey" );
        assertEquals( a[4], "boing" );
    }
}

