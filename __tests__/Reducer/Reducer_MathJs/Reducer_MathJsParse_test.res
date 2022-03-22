module MJ=Reducer.MathJs.Parse
module Result = Belt.Result

open Jest
open Expect

let expectParseToBe = (expr, answer) =>
  MJ.parse(expr) -> Result.flatMap(MJ.castNodeType) -> MJ.showResult
  -> expect -> toBe(answer)

describe("MathJs parse", () => {

  describe("literals operators paranthesis", () => {
    test("1", () => expectParseToBe("1", "1") )
    test("'hello'", () => expectParseToBe("'hello'", "'hello'") )
    test("true", () => expectParseToBe("true", "true") )
    test("1+2", () => expectParseToBe("1+2", "add(1, 2)") )
    test("add(1,2)", () => expectParseToBe("add(1,2)", "add(1, 2)") )
    test("(1)", () => expectParseToBe("(1)", "(1)") )
    test("(1+2)", () => expectParseToBe("(1+2)", "(add(1, 2))") )
  })

  describe( "variables", () => {
    Skip.test("define", () => expectParseToBe("x = 1", "???") )
    Skip.test("use", () => expectParseToBe("x", "???") )
  })

  describe( "functions", () => {
    Skip.test("define", () => expectParseToBe("identity(x) = x", "???") )
    Skip.test("use", () => expectParseToBe("identity(x)", "???") )
  })

  describe( "arrays", () => {
    test("empty", () => expectParseToBe("[]", "[]") )
    test("define", () => expectParseToBe("[0, 1, 2]", "[0, 1, 2]") )
    test("define with strings", () =>
      expectParseToBe("['hello', 'world']", "['hello', 'world']") )
    Skip.test("range", () => expectParseToBe("range(0, 4)", "range(0, 4)") )
    Skip.test("use", () => expectParseToBe("[1,2,3], index(1))", "???") )
  })

  describe( "records", () => {
    Skip.test("define", () => expectParseToBe("{a: 1, b: 2}", "???") )
    Skip.test("use", () => expectParseToBe("r.prop", "???") )
  })

  describe( "comments", () => {
    Skip.test("define", () => expectParseToBe("# This is a comment", "???") )
  })

  describe( "if statement", () => {
    Skip.test("define", () => expectParseToBe("if (true) { 1 } else { 0 }", "???") )
  })

})
