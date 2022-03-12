module Ctv = ReducerExternal.CodeTreeValue
open Jest
open Expect


describe("CodeTreeValue", () => {
  test("showArgs", () =>
    expect([Ctv.CtvNumber(1.), Ctv.CtvString("a")]->Ctv.showArgs)->toBe("1, 'a'")
  )
})
