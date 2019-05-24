import IterRange.range as range;
// using IterRange;
using IterChain;
using IterDup;
using IterLoop;
using Lambda;

/*
 * For now we just want to study the dump
 * a see which iterator get inlined, and how.
 */
class BenchALotOfChainedIterators {
    public static function main() {
        range(0, 10).dup().loop(2).array();      
        for (x in range(0, 10).dup())
            trace(x);      
    }
}
