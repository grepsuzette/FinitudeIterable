import haxe.unit.TestRunner;
import haxe.unit.TestCase;
import IterLoop;
using IterReverse;
using Lambda;

class TestIterReverse extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterReverse());
        runner.run();
    }

    public function test_reverse_simple() {
        var a = [1,2,3].iterReverse().array();
        assertEquals(a.length, 3);
        assertEquals(a[0], 3);
        assertEquals(a[1], 2);
        assertEquals(a[2], 1);
    }

    public function test_reverse_empty() {
        var a = [].iterReverse().array();
        assertEquals(a.length, 0);
    }

    public function test_reverse_list() {
        var l = new List<String>();
        l.add("a");
        l.add("b");
        l.add("c");
        var exp = ["c", "b", "a"];
        for (i in new IterDual(l.iterReverse(), exp)) 
            assertEquals(i._1, i._2);
    }

    public function test_throw_when_infinite() {
        var err = false;
        try {
            for (i in new IterLoop([44], IterLoop.INFINITY)._iterReverse()) 
                trace(i);
        }
        catch (d:Dynamic) { err = true; }
        assertTrue(err);
    }
    
    public function test_throw_when_infinite_macro() {
        var err = false;
        try {
            for (i in new IterLoop( [44], IterLoop.INFINITY).iterReverse()
            ) trace(i);
        }
        catch (d:Dynamic) { err = true; }
        assertTrue(err);
    }
}

