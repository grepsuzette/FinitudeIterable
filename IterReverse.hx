package finitudeiterable;

import IterReverse;
import FinitudeIterable;
using Lambda;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
#end

/**
 * A reverse iterator, the constructor can work with an array only, 
 * but the static function iterReverse() can work with any iterable.
 */
class IterReverse<T> {
    var a:Array<T>;
    var i:Int;
    public inline function new(b:Array<T>) { a = b; i = b.length; }
    public inline function hasNext():Bool return i > 0;
    public inline function next():T return a[--i];
    public inline function iterator():IterableIterator<T> return new IterReverse<T>(a);


    /*
     * Prefer to use iterReverse() instead of this function
     * (this one, "_iterReverse", being the fallback version)
     * With iterReverse() the prototype is similar to this one but it uses macro
     *  to optimize away an .array() call if the iterable is already an array.
     * @throw when "a" is an infinite FinitudeIterable.
     */
    public inline static function _iterReverse<T>(a:Iterable<T>):IterableIterator<T>
       return new IterReverse(Std.is(a, Array) ? cast a : IterReverse.arrayOrEmpty(a) ); 

    // @throw when "a" is an infinite FinitudeIterable.
    public static function arrayOrEmpty<T>(a:Iterable<T>):Array<T>
    {
        if ((Std.is(a, FinitudeIterable) 
            && cast (a, FinitudeIterable).isInfiniteIter())) { 
                throw "Cannot IterReverse infinite iterables";
        }
        else return Lambda.array(a);
    }

    /**
     * Create an new IterReverse, not just for arrays but for any Iterable.
     * @param (a:Iterable<T>
     * @return IterableIterator<T>
     * @throw when "a" is an infinite FinitudeIterable (on run-time)
     *
     * The following is a macro function that optimizes away the test 
     * for Array and that gets inlined to either:
     *
     *  - new IterReverse(a) (if a is Array)
     *  - new IterReverse(a.array()) (if a is Iterable)
     *
     * @sa _iterReverse() for an alternate version, without macro.
     */ 
    macro public inline static function iterReverse<T>(a:ExprOf<Iterable<T>>):Expr {
        var t = Context.follow(Context.typeof(a));
        try switch (t) {
            case TInst(_.get().name => "Array", _): 
                return ${ macro new IterReverse(cast $a) };
            case _:
                return ${ macro new IterReverse(IterReverse.arrayOrEmpty($a)) };
        } 
        catch (s:String) {
            Context.warning("IterReverse: Macro failed to determine types, "
                + "falling back to generic iterReverse()" + s, 
                Context.currentPos()    
            );
            return ${ macro IterReverse._rt_iterReverse($a) };
        }
    }

}

