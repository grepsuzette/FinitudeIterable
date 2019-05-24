import IterRangeMacro.rangeM as range;
using IterSustain;
using IterDup;
using IterLoop;
using IterMeet;
using IterPart;
using IterRandom;
using Demo1.IterString;
using Demo1.IterStr;
using Lambda;

@:forward
abstract IterStr(IterString) from (IterString) to (IterString) {
    public function new(s:String) this = new IterString(s);
    @:from public static function eachChar(s:String) return new IterStr(s);
    @:from public static function fromString(s:String) return new IterStr(s);
    @:to public function toString():String return this.array().join("");
}

class IterString {
    var s:String;
    var i:Int;
    var l:Int;
    public inline function new(s:String) { this.s = s; l = s.length; i = 0; }
    public inline function iterator() return new IterString(s);
    public inline function hasNext() return i < s.length;
    public inline function next() return s.substr(i++, 1); 
    public static function iter(s:String) return new IterString(s);
    public static function str(itr:Iterable<String>):String return itr.array().join("");
}

class Demo1 {
    public static function tr(s:Dynamic) trace(s);
    public static function sep() trace("-------------------------------");

    public static function main() {
        var s = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        sep();
        tr("'BONJOUR' . iterSustain(10): " + "BONJOUR" . iter()     . sustain(10)     . str() );
        tr("'BONJOUR' . iterDup(3): "      + "BONJOUR" . iter()     . dup(3)          . array() );
        tr("'BONJOUR' . iterDup(3): "      + "BONJOUR" . split("")  . dup(3)          . str() );
        tr("'BONJOUR' . iterPingPong(1): " + "BONJOUR" . split("")  . iterPingPong(1) . array() );
        tr("'BONJOUR' . iterPingPong(1): " + "BONJOUR" . iter()     . iterPingPong(1) . array() );
        tr("'BONJOUR' . iterRandom(3): "   + "BONJOUR" . split("")  . iterRandom()    . array() );
        tr("'BONJOUR' . iterRandom(3): "   + "BONJOUR" . eachChar() . iterRandom()    . array() );

        sep();
        tr("Several orders for iterator IterMeet: ");
        for (i in [0,1,-1,2]) tr( 'meet($i): ' + s.split("").iterMeet(cast i).array().join("") );

        sep();
        tr("Several orders for iterator IterPart: ");
        for (i in [1,-1, 2]) tr( 'part($i): ' + s.split("").iterPart(cast i).array().join("") );
    }

}
