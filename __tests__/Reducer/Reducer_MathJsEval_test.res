module MathJsEval = Reducer_MathJsEval
module Ctv = ReducerExternal.CodeTreeValue
module Rerr = Reducer_Error

open Jest
open ExpectJs

describe("eval", () => {
    test("Number", () => expect(MathJsEval.eval("1"))
    -> toEqual(Ok(Ctv.CtvNumber(1.))) )
    test("Number expr", () => expect(MathJsEval.eval("1-1"))
    -> toEqual(Ok(Ctv.CtvNumber(0.))) )
    test("String", () => expect(MathJsEval.eval("'hello'"))
    -> toEqual(Ok(Ctv.CtvString("hello"))) )
    test("String expr", () => expect(MathJsEval.eval("concat('hello ','world')"))
    -> toEqual(Ok(Ctv.CtvString("hello world"))) )
    test("Boolean", () => expect(MathJsEval.eval("true"))
    -> toEqual(Ok(Ctv.CtvBool(true))) )
    test("Boolean expr", () => expect(MathJsEval.eval("2>1"))
    -> toEqual(Ok(Ctv.CtvBool(true))) )
})

describe("errors", () => {
  // All those errors propagete up and are returned by the resolver
  test("unknown function", () => expect(MathJsEval.eval("testZadanga()"))
  -> toEqual(Error(Rerr.RerrJs(Some("Undefined function testZadanga"), Some("Error")))))

  test("unknown answer type", () => expect(MathJsEval.eval("1+1i"))
  -> toEqual(Error(Rerr.RerrTodo("Unhandled MathJs type: object"))))
})
