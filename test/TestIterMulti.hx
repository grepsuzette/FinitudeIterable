import haxe.unit.TestRunner;
import haxe.unit.TestCase;
import IterRange.range as range;
import IterMulti.multi as multi;
import IterLoop.loop as loop;
import IterDup.dup as dup;
import IterSustain.sustain as sustain;

using IterRange;
using IterMulti;
using IterLoop;
using Lambda;

class TestIterMulti extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterMulti());
        runner.run();
    }

    public function test_1() {
        var a = [2,3,4];
        var b = [6,7,8];
        for (i in new IterMulti([a, b])) {
            assertFalse(i[0] == i[1]);
        }
        assertTrue(true);
    }

    // eq. but fast with import IterDual.dual as dual;
    public function test_2() {
        var a = [2,3,4];
        var b = [6,7,8];
        for (i in multi([a, b])) {
            assertFalse(i[0] == i[1]);
        }
        assertTrue(true);
    }


    public function test_words() {
        var names = [ 
            "biscuit", 
            "hat", 
            "hammer", 
            "tv set", 
            "desk", 
            "window", 
            "man" 
        ];
        var adjectives = [ "dubious", "insane", "gorgeous" ];
        // trace( multi([names, adjectives], Loop).array() );     // this associates them
        
        assertEquals( multi( [names, adjectives], Loop ).map( 
                function(p) return p[1] + " " + p[0]
            ).last(), 
            "dubious man"
        );
    }


    public function test_trinidad_Null() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // pater must have apple, fili must have pear, and spiritus have null
                multi([
                        ["pater", "fili", "spiritus"], 
                        fruits
                    ], Null
                ).list().last()[1],
                null
        );
        
    }

    public function test_trinidad_Loop() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // this time spiritus must have apple as well
                multi([["pater", "fili", "spiritus"], fruits], Loop).list().last()[1],
                "apple"
        );
        
    }

    public function test_trinidad_Cut() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // this time there should not even have a spiritus entry:
                multi([["pater", "fili", "spiritus"], fruits], Cut).array().length,
                2
        );
        
    }

    public function test_trinidad_DefaultIsCut() {
        var fruits = ["apple", "pear"];
        assertEquals(
                // this time there should not even have a spiritus entry:
                multi([["pater", "fili", "spiritus"], fruits]).array().length,
                2
        );
        
    }


    // -------------------------------------------------- 
    // Up to now, we tested multi against dual tests
    // Now let's put some more serious tests.
    // -------------------------------------------------- 

    public function test_3arrays() {
        var a = 1;
        var b = 4;
        var c = 7;
        for (i in multi([[1,2,3], [4,5,6], [7,8,9]])) {
            // Those mandatory casts are unfortunate and 
            //  I don't really see what we can do about them...
            assertEquals(cast i[0], a++);
            assertEquals(cast i[1], b++);
            assertEquals(cast i[2], c++);
        }
    }

    public function test_triple_cut() {
        var trinidad    = ["pater",     "fili",     "spiritus"  ];
        var fruits      = ["banana",    "coconut",  "pineapple" ];
        var clothes     = ["bandana",   "bikini"                ];
        var out = [];
        for (i in new IterMulti([trinidad, fruits, clothes], Cut ))        
           out.push(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);

        assertEquals(out[0], "pater drinks banana juice wearing a bandana");
        assertEquals(out[1], "fili drinks coconut juice wearing a bikini");
        assertEquals(out.length, 2);
    }

    public function test_triple_null() {
        var trinidad    = ["pater",     "fili",     "spiritus"  ];
        var fruits      = ["banana",    "coconut",  "pineapple" ];
        var clothes     = ["bandana",   "bikini"                ];
        var out = [];

        for (i in new IterMulti([trinidad, fruits, clothes], Null ))
            out.push(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);

        assertEquals(out.length, 3);
        assertEquals(out[0], "pater drinks banana juice wearing a bandana");
        assertEquals(out[1], "fili drinks coconut juice wearing a bikini");
        assertEquals(out[2], "spiritus drinks pineapple juice wearing a null");
    }

    public function test_triple_loop() {
        var trinidad    = ["pater",     "fili",     "spiritus"  ];
        var fruits      = ["banana",    "coconut",  "pineapple" ];
        var clothes     = ["bandana",   "bikini"                ];
        var out = [];

        for (i in new IterMulti([trinidad, fruits, clothes], Loop ))
            out.push(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);

        assertEquals(out.length, 3);
        assertEquals(out[0], "pater drinks banana juice wearing a bandana");
        assertEquals(out[1], "fili drinks coconut juice wearing a bikini");
        assertEquals(out[2], "spiritus drinks pineapple juice wearing a bandana");
    }

    public function test_triple_sustain() {
        var trinidad    = ["pater",     "fili",     "spiritus"  ];
        var fruits      = ["banana",    "coconut",  "pineapple" ];
        var clothes     = ["bandana",   "bikini"                ];
        var out = [];

        for (i in new IterMulti([trinidad, fruits, clothes], Sustain ))
            out.push(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);

        assertEquals(out.length, 3);
        assertEquals(out[0], "pater drinks banana juice wearing a bandana");
        assertEquals(out[1], "fili drinks coconut juice wearing a bikini");
        assertEquals(out[2], "spiritus drinks pineapple juice wearing a bikini");
    }

    public function test_triple_random() {
        var trinidad    = ["pater",     "fili"                  ];
        var fruits      = ["banana",    "coconut",  "pineapple",
                           "pear",      "apple",    "mango",
                           "cherry",    "blueberry"             ];
        var out = [];

        // Here, the randomized entry is the shortest.
        // So while all fruits will be iterated normally,
        // the drinker would be choosen randomly after the 2 first 
        // iterations. Easier to check this with a print() but...
        for (i in new IterMulti([trinidad, fruits], Random ))
            out.push(i[0] + " drinks " + i[1] + " juice");
        // print(out);
        assertEquals(out.length, fruits.length);
        assertTrue(out.exists(function(s) return s != out[0]));
    }

    // -------------------------------------------------- 
    // Combination with other kind of iterators
    // These are a little more complex to understand
    // -------------------------------------------------- 

    public function test_triple_complex1() {
        var trinidad    = ["pater",     "fili",     "spiritus"  ];
        var fruits      = ["banana",    "coconut"               ];
        var clothes     = ["bandana"                            ];
        var out = [];

        for (i in new IterMulti(
            [trinidad, fruits.loop(), clothes], 
            Null            
// What to do w/ missing: Random, Cut, Null, Loop, Sustain/RepeatLast
// Ca servira quasi jamais en plus
// C'est du padding, et pas autre chose...
// pas besoin de distinguer les cas.
// Ou alors... d'une maniere ou d'une autre, indiquer que c'est un iterateur infini.
// .isInfiniteIterator
// Par ex, en implementant une interface.k
        ))
            out.push(i[0] + " drinks " + i[1] + " juice wearing a " + i[2]);
// trace(out);

        assertEquals(out.length, 3);
        assertEquals(out[0], "pater drinks banana juice wearing a bandana");
        assertEquals(out[1], "fili drinks coconut juice wearing a null");
        assertEquals(out[2], "spiritus drinks banana juice wearing a null");
    }
    
}

