import haxe.unit.TestRunner;
import haxe.unit.TestCase;
import IterRange.range as range;
import IterDual.dual as dual;

using IterRange;
using IterDual;
using Lambda;

class TestIterDual extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterDual());
        runner.run();
    }

    public function test_1() {
        var a = [2,3,4];
        var b = [6,7,8];
        for (i in new IterDual(a, b)) {
            assertFalse(i._1 == i._2);
        }
        assertTrue(true);
    }

    // eq. but fast with import IterDual.dual as dual;
    public function test_2() {
        var a = [2,3,4];
        var b = [6,7,8];
        for (i in dual(a, b)) {
            assertFalse(i._1 == i._2);
        }
        assertTrue(true);
    }


    public function test_words() {
        var names = [ "biscuit", "hat", "hammer", "tv set", "desk", "window", "man" ];
        var adjectives = [ "dubious", "insane", "gorgeous" ];
        // trace( dual(names, adjectives).list() );     // this associates them
        
        assertEquals( dual( names, adjectives, Loop ).map( 
                function(p) return p._2 + " " + p._1 
            ).last(), 
            "dubious man"
        );
    }


    public function test_trinidad_Null() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // pater must have apple, fili must have pear, and spiritus have null
                dual(["pater", "fili", "spiritus"], fruits, Null).list().last()._2,
                null
        );
        
    }

    public function test_trinidad_Loop() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // this time spiritus must have apple as well
                dual(["pater", "fili", "spiritus"], fruits, Loop).list().last()._2,
                "apple"
        );
        
    }

    public function test_trinidad_Cut() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // this time there should not even have a spiritus entry:
                dual(["pater", "fili", "spiritus"], fruits, Cut).array().length,
                2
        );
        
    }

    public function test_trinidad_DefaultIsCut() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // this time there should not even have a spiritus entry:
                dual(["pater", "fili", "spiritus"], fruits).array().length,
                2
        );
        
    }
}

