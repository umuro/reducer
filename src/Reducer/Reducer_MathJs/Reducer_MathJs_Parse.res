/*
  MathJs Nodes
*/
module JsG = Reducer_Js_Gate
module RLE = Reducer_ListExt
module Rerr = Reducer_Error

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

let castNodeType = (node: node) => switch node["type"] {
  | "ConstantNode" => node -> castConstantNode -> MjConstantNode -> Ok
  | "ParenthesisNode" => node -> castParenthesisNode -> MjParenthesisNode -> Ok
  | "FunctionNode" => node -> castFunctionNode -> MjFunctionNode -> Ok
  | "OperatorNode" => node -> castOperatorNode -> MjOperatorNode -> Ok
  | _ => Rerr.RerrTodo("Argg, unhandled MathJsNode: " ++ node["type"])-> Error
}

let rec showResult = (rmjnode: result<mjNode, Rerr.reducerError>): string => switch rmjnode {
  | Error(e) => Rerr.showError(e)
  | Ok(MjConstantNode(cnode)) => Js.String.make(cnode["value"])
  | Ok(MjParenthesisNode(pnode)) => "("++ showResult(castNodeType(pnode["content"])) ++")"
  | Ok(MjFunctionNode(fnode)) => fnode["fn"]++"("
    ++ (
      fnode["args"]
      -> Belt.Array.map( a => showResult(castNodeType(a)) )
      -> Belt.List.fromArray
      -> RLE.interperse(", ")
      -> Belt.List.toArray
      -> Js.String.concatMany("")
    ) ++")"
  | Ok(MjOperatorNode(fnode)) => fnode["fn"]++"("
      ++ (
        fnode["args"]
        -> Belt.Array.map( a => showResult(castNodeType(a)) )
        -> Belt.List.fromArray
        -> RLE.interperse(", ")
        -> Belt.List.toArray
        -> Js.String.concatMany("")
      ) ++")"
}
