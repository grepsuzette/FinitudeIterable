package finitudeiterable;

import IterSustain;
import FinitudeIterable;

/**
 * In musical theory, a trill is a repeated alternation of a note with the next 
 * note in the scale, so as to replace a sustained note.
 *
 * IterTrill is a conveniency alias for a special kind of IterSustain that repeat 
 * the last 2 elements of an iterable. 
 *
 * These 2 values are repeated indefinitely or for some extra times (in addition
 * to their initial appearance in the iterable). So using e.g. 3 for xtratimes
 * will result in 6 additional values for a trill.
 *
 * Some examples
 * -------------
 *
 * ```haxe
 *
 * import IterRange.range as range;
 * using IterSustain;
 * using IterTrill;
 *
 * // Infinite
 *
 * ["fish", "monkey", "human"].sustain(); // fish,monkey,human,human,human, ...
 * ["fish", "monkey", "human"].trill();   // fish,monkey,human,monkey,human, ...
 * range(0,5).loopLastN(3);               // 0,1,2,3,4,2,3,4,2,3,4,2,3,4,2,3,4. ...
 *
 * // Finite
 *
 * ["fish", "monkey", "human"].sustain(1);// fish,monkey,human,human
 * ["fish", "monkey", "human"].trill(1);  // fish,monkey,human,monkey,human
 * range(0,5).loopLastN(3,2);             // 0,1,2,3,4,2,3,4,2,3,4
 *
 * ```
 *
 * IterTrill does not add weight if you use IterSustain
 * ----------------------------------------------------
 * Everything is implemented in IterTrill already and the functions here are
 * mere inlines.
 */
class IterTrill<T> implements FinitudeIterable extends IterSustain<T> {
    public inline function new(itr:Iterable<T>, xtratimes:Int=1<<30)
        super(itr, xtratimes, Trill);
    public inline static function trill<T>(itr:Iterable<T>, xtratimes:Int=1<<30):IterableIterator<T>
        return IterSustain.trill(itr, xtratimes);
}
