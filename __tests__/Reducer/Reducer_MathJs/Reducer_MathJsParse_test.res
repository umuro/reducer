module MJ=Reducer.MathJs.Parse
module Result = Belt.Result

open Jest
// open Expect
open ExpectJs

describe("MathJs parse", () => {

  describe("literals operators paranthesis", () => {
    test("1", () =>
      switch MJ.parse("1") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjConstantNode(node)) => expect( node ) -> toMatchObject( {"type": "ConstantNode", "value": 1} )
      | _ => assert false
      })
    test("'hello'", () =>
      switch MJ.parse("'hello'") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjConstantNode(node)) => expect( node ) -> toMatchObject( {"type": "ConstantNode","value": "hello"} )
      | _ => assert false
    })
    Skip.test("true", () =>
      switch MJ.parse("true") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjConstantNode(node)) => expect( node ) -> toMatchObject( {"type": "ConstantNode","value": true} )
      | _ => assert false
    })
    test("1+2", () =>
      switch MJ.parse("1+2") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjOperatorNode(node)) => expect( node ) -> toMatchObject( {"type": "OperatorNode", "fn": "add"} )
      | _ => assert false
    })
    test("add(1,2)", () =>
      switch MJ.parse("add(1,2)") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjFunctionNode(node)) => expect( node ) -> toMatchObject( {"type": "FunctionNode", "fn": {"name": "add"}} )
      | _ => assert false
    })
    test("(1)", () =>
      switch MJ.parse("(1)") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "ParenthesisNode", "content": {"value": 1}} )
      | _ => assert false
    })
    test("(1+2)", () =>
      switch MJ.parse("(1+2)") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "ParenthesisNode", "content": {"type": "OperatorNode"}} )
      | _ => assert false
    })
  })

  describe( "variables", () => {
    Skip.test("define", () =>
      switch MJ.parse("x = 1") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
    Skip.test("use", () =>
      switch MJ.parse("x") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
  })

  describe( "functions", () => {
    Skip.test("define", () =>
      switch MJ.parse("identity(x) = x") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
    Skip.test("use", () =>
      switch MJ.parse("identity(x)") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
  })

  describe( "arrays", () => {
    Skip.test("empty", () =>
      switch MJ.parse("[]") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
    Skip.test("define", () =>
      switch MJ.parse("[0,1,2]") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
    Skip.test("define with strings", () =>
      switch MJ.parse("['hello', 'world']") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
    Skip.test("range", () =>
      switch MJ.parse("range(0, 4)") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
    Skip.test("use", () =>
      switch MJ.parse("subset([1,2,3], index(1))") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
  })

  describe( "records", () => {
    Skip.test("define", () =>
      switch MJ.parse("{a: 1, b: 2}") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
    Skip.test("use", () =>
      switch MJ.parse("r.prop") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
  })

  describe( "comments", () => {
    Skip.test("define", () =>
      switch MJ.parse("# This is a comment") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
  })

  describe( "if statement", () => {
    Skip.test("define", () =>
      switch MJ.parse("if (true) { 1 } else { 0 }") -> Result.flatMap(p => p -> MJ.castNodeType) {
      | Ok(MJ.MjParenthesisNode(node)) => expect( node ) -> toMatchObject( {"type": "xxx"} )
      | _ => assert false
    })
  })

})
