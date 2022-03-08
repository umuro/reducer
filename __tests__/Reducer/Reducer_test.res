module CT = Reducer.CodeTree
// CT.showResult converts a tree to string

open Jest
open Expect

describe("parse", () => {
  // Test the MathJs parser compatibility
  // Those tests show that there is a semantic mapping from MathJs to CodeTree
  // Reducer.parse is called by Reducer.eval

  test("1", () =>
    expect( Reducer.parse("1")->CT.showResult ) -> toBe("Ok(1)"))
  test("(1)", () =>
      expect( Reducer.parse("(1)")->CT.showResult ) -> toBe("Ok(1)"))
  test("1+2", () =>
      expect( Reducer.parse("1+2")->CT.showResult ) -> toBe("Ok((:add 1 2 ))"))
  test("add(1,2)", () =>
      expect( Reducer.parse("1+2")->CT.showResult ) -> toBe("Ok((:add 1 2 ))"))
  test("1+2*3", () =>
      expect( Reducer.parse("1+2*3")->CT.showResult ) -> toBe("Ok((:add 1 (:multiply 2 3 ) ))"))
  // TODO test not yet implemented semantic mapping
})

describe("eval", () => {

  test("toBe", () =>
    expect(1 + 2) -> toBe(3))
})

// TODO Error classes
// TODO test div by 0
// TODO test syntax error

// TODO language basics
// TODO eval + - / * > >= < <= == /= not and or
