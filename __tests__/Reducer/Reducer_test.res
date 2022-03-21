module CT = Reducer.CodeTree
module CTV = Reducer.Extension.CodeTreeValue

open Jest
open Expect

let expectParseToBe = (expr: string, answer: string) =>
  Reducer.parse(expr) -> CT.showResult -> expect -> toBe(answer)

let expectEvalToBe = (expr: string, answer: string) =>
  Reducer.eval(expr) -> CTV.showResult -> expect -> toBe(answer)

describe("parse", () => {
  // Test the MathJs parser compatibility
  // Those tests show that there is a semantic mapping from MathJs to CodeTree
  // Reducer.parse is called by Reducer.eval

  describe("expressions", () => {
    test("1", () => expectParseToBe("1", "Ok(1)") )
    test("(1)", () => expectParseToBe( "(1)", "Ok(1)" ) )
    test("1+2", () => expectParseToBe( "1+2", "Ok((:add 1 2))" ) )
    test("(1+2)", () => expectParseToBe( "1+2", "Ok((:add 1 2))" ) )
    test("add(1,2)", () => expectParseToBe( "1+2", "Ok((:add 1 2))" ) )
    test("1+2*3", () => expectParseToBe( "1+2*3", "Ok((:add 1 (:multiply 2 3)))" ) )
  })
  describe("arrays", () => {
    //Note. () is a empty list in Lisp
    //  The only builtin structure in Lisp is list. There are no arrays
    //  [1,2,3] becomes (1 2 3)
    test("empty", () => expectParseToBe( "[]", "Ok(())" ) )
    test("[1, 2, 3]", () => expectParseToBe( "[1, 2, 3]", "Ok((1 2 3))" ) )
    test("['hello', 'world']", () =>
      expectParseToBe( "['hello', 'world']", "Ok(('hello' 'world'))"
 ) )
  })
})

describe("eval", () => {
  // All MathJs operators and functions are builtin for string, float and boolean
  // .e.g + - / * > >= < <= == /= not and or
  // See https://mathjs.org/docs/expressions/syntax.html
  // See https://mathjs.org/docs/reference/functions.html
  describe("expressions", () => {
    test("1", () => expectEvalToBe( "1", "Ok(1)" ) )
    test("1+2", () => expectEvalToBe( "1+2", "Ok(3)" ) )
    test("(1+2)*3", () => expectEvalToBe( "(1+2)*3", "Ok(9)" ) )
  })

  describe("arrays", () => {
    //Note. () is a empty list in Lisp
    // The only builtin structure in Lisp is list
    Skip.test("empty", () => expectEvalToBe( "[]", "Ok([])" ) )
    Skip.test("[1, 2, 3]", () => expectEvalToBe( "[1, 2, 3]", "Ok([1, 2, 3])" ) )
    Skip.test("['hello', 'world']", () => expectEvalToBe( "['hello', 'world']", "?" ) )
  })
})

describe("test exceptions", () => {
  test("javascript exception", () =>
    expectEvalToBe( "jsraise('div by 0')", "Error(JS Exception: Error: 'div by 0')") )

  test("rescript exception", () =>
    expectEvalToBe( "resraise()", "Error(TODO: unhandled rescript exception)" ) )
})
