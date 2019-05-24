# Iterators: general iterators for Haxe

**IterVoid**:   Never hasNext().
**IterLoop**:   Iterate `n` times over an Iterable<T> before finishing (infinite when n is 1<<30)
**IterPart**:   Turn iterable into an array if necessary, virtually divide into `n` equal parts, iterate once alternatively each of these parts until all elements have been iterated. 
**IterMeet**:   Family of composite iterators that "meet in the middle", beginning on ends.
**IterArmy**:   A captain that in turns delegates each iteration to a different soldier then loops back to the first soldier.
**IterRandom**: 1. A random iterator where each element from an Iterable<T> is just returned once.
            2. An infinite iterator where elements get randomly picked from an Iterable<T>.
**IterRange**:  IntIterator that can operate on `Float` and have a step that can be negative.
**IterChain**:  Composite iterator passing control to the next subiterator after previous has finished, until the last has finished.
**IterDual**:   Composite typed iterator iterating two iterators in parallel and return a pair of their respective next(). Shortcomings are available in case not all subiterators have the same count of elements.
**IterMulti**:  Composite untyped iterator that iterate any number of iterators in parallel and return an array of their respective next(). Shortcomings are available in case not all subiterators have the same count of elements.
**IterDup**:    Iterator duplicating each element in the Iterable<T> `n` times before advancing to the next.
**IterSustain**: Runs normally over an Iterable<T> to finally have the last value yielded `n` times.
**IterTrill**:  1. 

```haxe
var a = [2,3,4];
var b = [6,7,8];
for (i in new IterDual(a, b)) {
    assertFalse(i[0] == i[1]);
}
assertFalse( dual(a, b).foreach( function(i) i._1 != i._2 ));

for (i in new IterDual(a, b)) {
    assertFalse(i._1 == i._2);
}
for (i in dual(a, b)) {
    assertFalse(i._1 == i._2);
}
for (i in new IterMulti([ "a" => a, "b" => b])) {
    assertFalse(i["a"] == i["b"]);
}
for (i in new IterDual([a, b], ["a", "b"])) {
    assertFalse(i["a"] == i["b"]);
}
for (i in dual([ "a" => a, "b" => b])) {
    assertFalse(i["a"] == i["b"]);
}

[4,1,5,63].keep(2);
[43,26,64,263,63].keepI(0...2);
listCities.keepX(even);
listOrganizations.skipX(even);
listCities.keepX(function(x) return x % 2 == 1);
listCities.filterI( function(t, i) return i % 2 == 0 && t != null );
range(0, 3).loop(2);                // 0, 1, 2, 0, 1, 2
range(0, 3).dup(0);                 // 
range(0, 3).dup(1);                 // 0, 1, 2
range(0, 3).dup(2);                 // 0, 0, 1, 1, 2, 2
range(0, 3).dup(3);                 // 0, 0, 0, 1, 1, 1, 2, 2, 2
range(0, 3).dup( [3].loop() );      // 0, 0, 0, 1, 1, 1, 2, 2, 2
range(0, 10).dupI( [3,2,1], Cut );  // 0, 0, 0, 1, 1, 2
range(0, 10).dupI( [3,2,1], GoOn ); // 0, 0, 0, 1, 1, 2, 3, 4, 5, 6,7,8,9
range(0, 3).dup();                  // 0, 0, 1, 1, 2, 2

dup(
    itr:Iterable<T>, 
    ?count:Null<Int>, 
    orIterable:Iterable<T>=null, 
    withDupShortcoming:IterDupShortcoming=null
);








