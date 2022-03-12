module CT = Reducer.CodeTree
module CTV = ReducerExternal.CodeTreeValue
module JsG = ReducerExternal_JsGate

open Jest
open Expect
describe("builtin exception", () => {
  test("MathJs Exception", () =>
    expect( Reducer.eval("testZadanga()") -> CTV.showResult ) -> toBe("Error(Function Not Found: testZadanga with args: )")
  )
})

// TODO language basics
// TODO eval + - / * > >= < <= == /= not and or
