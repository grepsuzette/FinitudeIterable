using Lambda;

class IterChain2<T> {
    public function new(a:Array<Iterable<T>>) { trace(a); }
    
    //    eg:  this works:   for (i in chain(range(0,10), range(100, 110))) trace(i);
    //         BUT NOT THIS:  for (i in chain(range(0,10), rangeDown(100, 50))) trace(i);
    //
    //         (@note range() and rangeDown() both are Iterator<Float> + Iterable<Float>) 
    //
    public macro static function chain<T>(arr:Array<haxe.macro.Expr>) {
        var a = [];
        for (e in arr) { a.push(e); }
        var args = macro $a{a};
        return macro new IterChain2($args);
    }

    public inline function next() return null;
    public function hasNext() return false;
    public function iterator() return this;
}

