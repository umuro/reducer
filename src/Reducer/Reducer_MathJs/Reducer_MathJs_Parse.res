/*
  MathJs Nodes
  We make MathJs Nodes strong-typed
*/
module JsG = Reducer_Js_Gate
module RLE = Reducer_ListExt
module Rerr = Reducer_Error

type reducerError = Rerr.reducerError

type node = {
  "type": string,
  "isNode": bool,
  "comment": string
}
//accessorNode
//arrayNode
type arrayNode = {
  ...node,
  "items": array<node>
}
external castArrayNode: node => arrayNode = "%identity"

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
  ...functionNode,
  "op": string,
}
external castOperatorNode: node => operatorNode = "%identity"
external castOperatorNodeToFunctionNode: operatorNode => functionNode = "%identity"

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

let parse = (expr: string): result<node, reducerError> =>
  try {
    Ok(parse__(expr))
  } catch {
  | Js.Exn.Error(obj) =>
    RerrJs(Js.Exn.message(obj), Js.Exn.name(obj))->Error
  }

type mjNode =
  | MjArrayNode(arrayNode)
  | MjConstantNode(constantNode)
  | MjFunctionNode(functionNode)
  | MjOperatorNode(operatorNode)
  | MjParenthesisNode(parenthesisNode)

let castNodeType = (node: node) => switch node["type"] {
  | "ArrayNode" => node -> castArrayNode -> MjArrayNode -> Ok
  | "ConstantNode" => node -> castConstantNode -> MjConstantNode -> Ok
  | "FunctionNode" => node -> castFunctionNode -> MjFunctionNode -> Ok
  | "OperatorNode" => node -> castOperatorNode -> MjOperatorNode -> Ok
  | "ParenthesisNode" => node -> castParenthesisNode -> MjParenthesisNode -> Ok
  | _ => Rerr.RerrTodo("Argg, unhandled MathJsNode: " ++ node["type"])-> Error
}

let showValue = (a: 'a): string => if (Js.typeof(a) == "string") {
  "'"++Js.String.make(a)++"'"
} else {
  Js.String.make(a)
}

let rec showResult = (rmjnode: result<mjNode, reducerError>): string => switch rmjnode {
  | Error(e) => Rerr.showError(e)
  | Ok(MjArrayNode(aNode)) => "["++ aNode["items"]->showNodeArray ++"]"
  | Ok(MjConstantNode(cNode)) => cNode["value"]->showValue
  | Ok(MjParenthesisNode(pNode)) => "("++ showResult(castNodeType(pNode["content"])) ++")"
  | Ok(MjFunctionNode(fNode)) =>
      fNode -> showFunctionNode
  | Ok(MjOperatorNode(opNode)) =>
      opNode -> castOperatorNodeToFunctionNode -> showFunctionNode
}
and let showFunctionNode = (fnode: functionNode): string =>
  fnode["fn"]++"("++ fnode["args"]->showNodeArray ++")"
and let showNodeArray = (nodeArray: array<node>): string =>
  nodeArray
  -> Belt.Array.map( a => showResult(castNodeType(a)) )
  -> Belt.List.fromArray
  -> RLE.interperse(", ")
  -> Belt.List.toArray
  -> Js.String.concatMany("")
