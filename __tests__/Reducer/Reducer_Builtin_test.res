module CT = Reducer.CodeTree
module Ctv = ReducerExternal.CodeTreeValue
module JsG = ReducerExternal_JsGate

open Jest
open Expect

describe("builtin", () => {
  // All MathJs functions are available (string, number, boolean)
  test("-1", () =>
    expect(Reducer.eval("-1")->Ctv.showResult)->toBe("Ok(-1)") )
  test("1-1", () =>
    expect(Reducer.eval("1-1")->Ctv.showResult)->toBe("Ok(0)") )
  test("2>1", () =>
    expect(Reducer.eval("2>1")->Ctv.showResult)->toBe("Ok(true)") )
  test("concat('a','b')", () =>
    expect(Reducer.eval("concat('a','b')")->Ctv.showResult)->toBe("Ok('ab')") )
})

describe("builtin exception", () => {
  //It's a pity that MathJs does not return error position
  test("MathJs Exception", () =>
    expect( Reducer.eval("testZadanga()") -> Ctv.showResult ) -> toBe("Error(JS Exception: Error: Undefined function testZadanga)")
  )
  test("MathJs Exception 2", () =>
    expect( Reducer.eval("1+1i") -> Ctv.showResult ) -> toBe("Error(TODO: Argg, unhandled MathJsNode: SymbolNode)")
  )
})

// TODO language basics
// TODO eval + - / * > >= < <= == /= not and or
