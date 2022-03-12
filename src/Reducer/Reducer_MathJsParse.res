/*
  MathJs Nodes
*/
module Rerr = Reducer_Error
module JsG = ReducerExternal_JsGate

type node = {
  "type": string,
  "isNode": bool,
  "comment": string
}
//accessorNode
//arrayNode
//assignmentNode
//blockNode
//conditionalNode
//constantNode
type constantNode = {
  ...node,
  "value": unit
}
external castConstantNode: node => constantNode = "%identity"

//functionAssignmentNode
//functionNode
type functionNode = {
  ...node,
  "fn": string,
  "args": array<node>
}
external castFunctionNode: node => functionNode = "%identity"

//indexNode
//objectNode
//operatorNode
type operatorNode = {
  ...node,
  "op": string,
  "fn": string,
  "args": array<node>
}
external castOperatorNode: node => operatorNode = "%identity"

//parenthesisNode
type parenthesisNode = {
  ...node,
  "content": node
}
external castParenthesisNode: node => parenthesisNode = "%identity"

//rangeNode
//relationalNode
//symbolNode

/*
  MathJs Parser
*/
@module("mathjs") external parse__: string => node = "parse"

let parse = (expr: string): result<node, Rerr.reducerError> =>
  try {
    Ok(parse__(expr))
  } catch {
  | Js.Exn.Error(obj) =>
    RerrJs(Js.Exn.message(obj), Js.Exn.name(obj))->Error
  }

type mjNode =
  | MjConstantNode(constantNode)
  | MjFunctionNode(functionNode)
  | MjOperatorNode(operatorNode)
  | MjParenthesisNode(parenthesisNode)

let castNodeType = (node) => switch node["type"] {
  | "ConstantNode" => node -> castConstantNode -> MjConstantNode -> Ok
  | "FunctionNode" => node -> castFunctionNode -> MjFunctionNode -> Ok
  | "OperatorNode" => node -> castOperatorNode -> MjOperatorNode -> Ok
  | "ParenthesisNode" => node -> castParenthesisNode -> MjParenthesisNode -> Ok
  | _ => Rerr.RerrTodo("Argg, unhandled MathJsNode: " ++ node["type"])-> Error
}
