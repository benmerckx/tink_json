package;

import haxe.PosInfos;
import haxe.unit.TestCase;
import tink.json.Parser;

typedef Foo = { foo:Float, bar:Array<{ flag: Bool, ?buzz:Array<{ word: String }> }> };
typedef Cons<T> = Null<{
  head:T,
  ?tail:Cons<T>
}>;

class ParserTest extends TestCase {
  
  function testStructEq() {
    structEq( { foo: [{ bar: [4] }]}, { foo: [{ bar: [4] }]} );
    try {
      structEq( { foo: [{ bar: [4] }]}, { foo: [{ bar: [5] }]} );
      assertTrue(false);
    }
    catch (e:Dynamic) {
      assertTrue(true);
    }
  }
  
  function measure<A>(s:String, f:Void->A, ?pos:haxe.PosInfos) {
    function stamp()
      return
        #if java
          Sys.cpuTime();
        #else
          haxe.Timer.stamp();
        #end
        
    var start = stamp();
    var ret = f();
    haxe.Log.trace('$s took ${stamp() - start}', pos);
    return ret;
  }
  
  /*public function testPerformance() {
    var o = {
      blub: [
        { foo: [ { bar: [4] } ] }, 
        { foo: [ { bar: [4] } ] } 
      ]
    };
    
    
    for (i in 0...100000)
      haxe.Json.stringify(o);
      
    measure('haxe stringify', function () 
      for (i in 0...10000)
        haxe.Json.stringify(o)
    );
    
    
    for (i in 0...100000)
      tink.Json.stringify(o);
      
    measure('tink stringify', function () 
      for (i in 0...10000)
        tink.Json.stringify(o)
    );
        
    var s = tink.Json.stringify(o);
    
    
    for (i in 0...100000)
      o = haxe.Json.parse(s);
      
    measure('haxe parse', function () 
      for (i in 0...10000)
        o = haxe.Json.parse(s)
    );
    
    
    for (i in 0...100000)
      o = tink.Json.parse(s);
    
    measure('tink parse', function () 
      for (i in 0...10000)
        o = tink.Json.parse(s)
    );
    
  }*/
  public function testParser() {
    
    Helper.roundtrip({
      foo: true,
      bar: [
        {
          werg: 'foo',
          fwerlk: [{ baz: 5 }, { baz: 15 }]
        }
      ]
    });
    
    var x: Foo = {
      foo: 4.5,
      bar: [{
        flag: true,
      }, {
        flag: false,
        buzz: [{ word: 'blub' }]
      }]
    }
    
    Helper.roundtrip(x);
    
    var l:Cons<Int> = {
      head: 4,
      tail: {
        head: 3,
        tail: {
          head: 2
        }
      }
    };
    
    Helper.roundtrip(l);
  }
	function fail( reason:String, ?c : PosInfos ) : Void {
		currentTest.done = true;
    currentTest.success = false;
    currentTest.error   = reason;
    currentTest.posInfos = c;
    throw currentTest;
	}  
  
  function structEq<A>(expected:A, found:A) {
    
    var eType = Type.typeof(expected),
        fType = Type.typeof(found);
    if (!eType.equals(fType))    
      fail('$found should be $eType but is $fType');
    
    assertTrue(true);
    
    switch eType {
      case TNull, TInt, TFloat, TBool, TClass(String):
        assertEquals(expected, found);
      case TFunction:
        throw 'not implemented';
      case TObject:
        for (name in Reflect.fields(expected)) {
          structEq(Reflect.field(expected, name), Reflect.field(found, name));
        }
      case TClass(Array):
        var expected:Array<A> = cast expected,
            found:Array<A> = cast found;
            
        if (expected.length != found.length)
          fail('expected $expected but found $found');
        
        for (i in 0...expected.length)
          structEq(expected[i], found[i]);
          
      case TClass(cl):
        throw 'comparing $cl not implemented';
      case TEnum(e):
        throw 'not implemented';
        //assertEquals(Type.enumConstructor(expected), Type.enumConstructor(found));
      case TUnknown:
        throw 'not implemented';
    }
  }  
}