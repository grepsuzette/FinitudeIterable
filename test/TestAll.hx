import haxe.unit.TestCase;
import haxe.unit.TestRunner;

import TestIterArmy;
import TestIterRange;
import TestIterMeet;
import TestIterLoop;
import TestIterPart;
import TestIterRandom;
import TestIterVoid;
import TestIterDual;
import TestIterMulti;
import TestIterChain;
import TestIterSustain;
import TestIterTrill;
import TestIterLoopLastN;
import TestIterReverse;
import TestIterPingPong;

class TestAll extends TestCase {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new TestIterArmy());
        runner.add(new TestIterLoop());
        runner.add(new TestIterMeet());
        runner.add(new TestIterPart());
        runner.add(new TestIterRandom());
        runner.add(new TestIterRange());
        runner.add(new TestIterVoid());
        runner.add(new TestIterDual());
        runner.add(new TestIterMulti());
        runner.add(new TestIterChain());
        runner.add(new TestIterSustain());
        runner.add(new TestIterTrill());
        runner.add(new TestIterLoopLastN());
        runner.add(new TestIterReverse());
        runner.add(new TestIterPingPong());
        runner.run();
    }
} 

