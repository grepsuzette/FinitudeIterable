import haxe.unit.TestCase;
import haxe.unit.TestRunner;

import IterArmy;
import IterVoid;
using Lambda;
using IterLoop;

class TestIterArmy extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterArmy());
        runner.run();
    }

    public function test_1() {
        var n = 0;

        for (i in new IterArmy<Int>([ 
            new IterVoid<Int>(), 
            new IterVoid<Int>() 
        ])) n++;

        assertEquals(0, n);
    }


    public function test_2() {
        var n = 0;

        var a = [];
        for (x in new IterArmy<Float>([ 
            new IterRange(0, 2, 1), 
            new IterRange(2, 5, 1) 
        ])) a.push(x);

        assertEquals(a[0], 0);
        assertEquals(a[1], 2);
        assertEquals(a[2], 1);
        assertEquals(a[3], 3);
        assertEquals(a[4], 4);
        assertEquals(a.length, 5);
    }

    public function test_partition_preconcept() {
        var n = 0;

        var a = [];
        for (x in new IterArmy<Float>([ 
            new IterRange( 0,10, 1), 
            new IterRange(10,20, 1), 
            new IterRange(20,30, 1), 
            new IterRange(30,40, 1), 
            new IterRange(40,50, 1), 
        ])) a.push(x);

        assertEquals ( a[0]     , 0  ) ;
        assertEquals ( a[1]     , 10 ) ;
        assertEquals ( a[2]     , 20 ) ;
        assertEquals ( a[3]     , 30 ) ;
        assertEquals ( a[4]     , 40 ) ;
        assertEquals ( a[5]     , 1  ) ;
        assertEquals ( a[6]     , 11 ) ;
        assertEquals ( a[7]     , 21 ) ;
        assertEquals ( a[8]     , 31 ) ;
        assertEquals ( a[9]     , 41 ) ;
        assertEquals ( a[10]    , 2  ) ;
        assertEquals ( a[11]    , 12 ) ;
        assertEquals ( a[12]    , 22 ) ;
        assertEquals ( a[13]    , 32 ) ;
        assertEquals ( a[14]    , 42 ) ;
        assertEquals ( a[15]    , 3  ) ;
        assertEquals ( a[16]    , 13 ) ;
        assertEquals ( a[17]    , 23 ) ;
        assertEquals ( a[18]    , 33 ) ;
        assertEquals ( a[19]    , 43 ) ;
        assertEquals ( a[20]    , 4  ) ;
        assertEquals ( a[21]    , 14 ) ;
        assertEquals ( a[22]    , 24 ) ;
        assertEquals ( a[23]    , 34 ) ;
        assertEquals ( a[24]    , 44 ) ;
        assertEquals ( a[25]    , 5  ) ;
        assertEquals ( a[26]    , 15 ) ;
        assertEquals ( a[27]    , 25 ) ;
        assertEquals ( a[28]    , 35 ) ;
        assertEquals ( a[29]    , 45 ) ;
        assertEquals ( a[30]    , 6  ) ;
        assertEquals ( a[31]    , 16 ) ;
        assertEquals ( a[32]    , 26 ) ;
        assertEquals ( a[33]    , 36 ) ;
        assertEquals ( a[34]    , 46 ) ;
        assertEquals ( a[35]    , 7  ) ;
        assertEquals ( a[36]    , 17 ) ;
        assertEquals ( a[37]    , 27 ) ;
        assertEquals ( a[38]    , 37 ) ;
        assertEquals ( a[39]    , 47 ) ;
        assertEquals ( a[40]    , 8  ) ;
        assertEquals ( a[41]    , 18 ) ;
        assertEquals ( a[42]    , 28 ) ;
        assertEquals ( a[43]    , 38 ) ;
        assertEquals ( a[44]    , 48 ) ;
        assertEquals ( a[45]    , 9  ) ;
        assertEquals ( a[46]    , 19 ) ;
        assertEquals ( a[47]    , 29 ) ;
        assertEquals ( a[48]    , 39 ) ;
        assertEquals ( a[49]    , 49 ) ;
        assertEquals ( a.length , 50 ) ;
    }

    public function test_reading_from_2_arrays_simple() {
        // suppose you want to read from 2 arrays?
        // alternating values of squares and cubes:
        var squares = [ for (i in 0...10) i*i ];
        var cubes = [ for (i in 0...10) i*i*i ];

        // trace ( new IterArmy<Int>([ squares.iterator(), cubes.iterator() ]).array() );
        assertTrue(true);
    }
    
    public function test_reading_from_2_arrays() {
        // suppose you want to read from 2 arrays?
        // alternating values of squares and cubes:
        var a = [ for (i in 0...10) i ];
        assertEquals( new IterArmy<Float>([ 
            a.map( Math.pow.bind(_, 2) ).iterator(),
            a.map( Math.pow.bind(_, 3) ).iterator(),
            // a.map( Math.pow(_, 4) ),
            // a.map( Math.pow(_, 5) ),
        ]).array().length, 20);
    }

    public function test_reading_from_4_arrays() {
        var a = [ for (i in 0...10) i ];
        assertEquals(new IterArmy<Float>([ 
                    a.map( Math.pow.bind(_, 2) ).iterator(),
                    a.map( Math.pow.bind(_, 3) ).iterator(),
                    a.map( Math.pow.bind(_, 4) ).iterator(),
                    a.map( Math.pow.bind(_, 5) ).iterator(),
                ]
            ).array().length, 40);
    }

    public function compareArrays<T>(a:Array<T>, b:Array<T>):Bool {
        if (a.length != b.length) return false;
        for (i in 0...a.length) if (a[i] != b[i]) return false;
        return true;
    }


} 

