module MJ=Reducer.MathJs.Parse
module Result = Belt.Result

open Jest
// open Expect
open ExpectJs

describe("MathJs parse", () => {

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
