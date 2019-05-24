import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestIterVoid extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterVoid());
        runner.run();
    }

    public function test_me() {
        var n = 0;
        for (x in new IterVoid()) n++; 
        assertEquals(n, 0);
    }
} 
