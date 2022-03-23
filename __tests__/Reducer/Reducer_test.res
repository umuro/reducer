open Jest
open Reducer_TestHelpers

describe("using mathjs parse", () => {
  // Test the MathJs parser compatibility
  // Those tests show that there is a semantic mapping from MathJs to CodeTree
  // Reducer.parse is called by Reducer.eval

  describe("expressions", () => {
    test("1", () => expectParseToBe("1", "Ok(1)"))
    test("(1)", () => expectParseToBe( "(1)", "Ok(1)"))
    test("1+2", () => expectParseToBe( "1+2", "Ok((:add 1 2))"))
    test("(1+2)", () => expectParseToBe( "1+2", "Ok((:add 1 2))"))
    test("add(1,2)", () => expectParseToBe( "1+2", "Ok((:add 1 2))"))
    test("1+2*3", () => expectParseToBe( "1+2*3", "Ok((:add 1 (:multiply 2 3)))"))
  })
  describe("arrays", () => {
    //Note. () is a empty list in Lisp
    //  The only builtin structure in Lisp is list. There are no arrays
    //  [1,2,3] becomes (1 2 3)
    test("empty", () => expectParseToBe( "[]", "Ok(())"))
    test("[1, 2, 3]", () => expectParseToBe( "[1, 2, 3]", "Ok((1 2 3))"))
    test("['hello', 'world']", () =>
      expectParseToBe( "['hello', 'world']", "Ok(('hello' 'world'))"))
    test("index", () => expectParseToBe("([0,1,2])[1]", "Ok((:internalAtIndex (0 1 2) (1)))"))
  })
  describe("records", () => {
    test("define", () =>
      expectParseToBe("{a: 1, b: 2}", "Ok((:internalConstructRecord (('a' 1) ('b' 2))))"))
    test("use", () =>
      expectParseToBe("record.property", "Ok((:internalAtIndex :record ('property')))"))
  })
})

describe("eval", () => {
  // All MathJs operators and functions are builtin for string, float and boolean
  // .e.g + - / * > >= < <= == /= not and or
  // See https://mathjs.org/docs/expressions/syntax.html
  // See https://mathjs.org/docs/reference/functions.html
  describe("expressions", () => {
    test("1", () => expectEvalToBe( "1", "Ok(1)"))
    test("1+2", () => expectEvalToBe( "1+2", "Ok(3)"))
    test("(1+2)*3", () => expectEvalToBe( "(1+2)*3", "Ok(9)"))
    // TODO more built ins
  })

  describe("arrays", () => {
    //Note. () is a empty list in Lisp
    // The only builtin structure in Lisp is list
    test("empty", () => expectEvalToBe( "[]", "Ok([])"))
    test("[1, 2, 3]", () => expectEvalToBe( "[1, 2, 3]", "Ok([1, 2, 3])"))
    test("['hello', 'world']", () => expectEvalToBe( "['hello', 'world']", "Ok(['hello', 'world'])"))
  })
})

describe("test exceptions", () => {
  test("javascript exception", () =>
    expectEvalToBe( "jsraise('div by 0')", "Error(JS Exception: Error: 'div by 0')"))

  test("rescript exception", () =>
    expectEvalToBe( "resraise()", "Error(TODO: unhandled rescript exception)"))
})
