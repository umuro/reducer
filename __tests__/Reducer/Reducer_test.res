module CT = Reducer.CodeTree
module CTV = Reducer.Extension.CodeTreeValue

open Jest
open Expect

describe("parse", () => {
  // Test the MathJs parser compatibility
  // Those tests show that there is a semantic mapping from MathJs to CodeTree
  // Reducer.parse is called by Reducer.eval

  describe("expressions", () => {
    test("1", () =>
      expect( Reducer.parse("1")->CT.showResult ) -> toBe("Ok(1)"))
    test("(1)", () =>
        expect( Reducer.parse("(1)")->CT.showResult ) -> toBe("Ok(1)"))
    test("1+2", () =>
        expect( Reducer.parse("1+2")->CT.showResult ) -> toBe("Ok((:add 1 2))"))
    test("(1+2)", () =>
            expect( Reducer.parse("1+2")->CT.showResult ) -> toBe("Ok((:add 1 2))"))
    test("add(1,2)", () =>
        expect( Reducer.parse("1+2")->CT.showResult ) -> toBe("Ok((:add 1 2))"))
    test("1+2*3", () =>
        expect( Reducer.parse("1+2*3")->CT.showResult ) -> toBe("Ok((:add 1 (:multiply 2 3)))"))
  })
  describe("arrays", () => {
    //Note. () is a empty list in Lisp
    test("empty", () => Reducer.parse("[]")->CT.showResult->expect->toBe("Ok(())"))
  })
})

describe("eval", () => {
  // All MathJs operators and functions are builtin (string, float, boolan)
  describe("expressions", () => {
    test("1", () =>
      expect( Reducer.eval("1") -> CTV.showResult ) -> toBe("Ok(1)"))
    test("1+2", () =>
      expect( Reducer.eval("1+2") -> CTV.showResult ) -> toBe("Ok(3)"))
    test("1+(2+3)", () =>
      expect( Reducer.eval("1+(2+3)") -> CTV.showResult ) -> toBe("Ok(6)"))
  })
})

describe("test exceptions", () => {
  test("javascript exception", () =>
    expect( Reducer.eval("jsraise('div by 0')") -> CTV.showResult ) -> toBe("Error(JS Exception: Error: 'div by 0')")
  )

  test("rescript exception", () =>
    expect( Reducer.eval("resraise()") -> CTV.showResult ) -> toBe("Error(TODO: unhandled rescript exception)")
  )

})
