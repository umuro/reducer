module Ctv = Reducer_Extension.CodeTreeValue
open Jest
open Expect


describe("CodeTreeValue", () => {
  test("showArgs", () =>
    expect([Ctv.CtvNumber(1.), Ctv.CtvString("a")]->Ctv.showArgs)
    ->toBe("1, 'a'")
  )

  test("showFunctionCall", () =>
    expect( ("fn", [Ctv.CtvNumber(1.), Ctv.CtvString("a")])->Ctv.showFunctionCall )
    ->toBe("fn(1, 'a')")
  )
})
