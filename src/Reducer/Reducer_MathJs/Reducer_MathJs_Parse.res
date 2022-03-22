/*
  MathJs Nodes
  We make MathJs Nodes strong-typed
*/
module AE = Reducer_ArrayExt
module JsG = Reducer_Js_Gate
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
type objectNode = {
  ...node,
  "properties": Js.Dict.t<node>
}
external castObjectNode: node => objectNode = "%identity"
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
  | MjObjectNode(objectNode)
  | MjOperatorNode(operatorNode)
  | MjParenthesisNode(parenthesisNode)

let castNodeType = (node: node) => switch node["type"] {
  | "ArrayNode" => node -> castArrayNode -> MjArrayNode -> Ok
  | "ConstantNode" => node -> castConstantNode -> MjConstantNode -> Ok
  | "FunctionNode" => node -> castFunctionNode -> MjFunctionNode -> Ok
  | "ObjectNode" => node -> castObjectNode -> MjObjectNode -> Ok
  | "OperatorNode" => node -> castOperatorNode -> MjOperatorNode -> Ok
  | "ParenthesisNode" => node -> castParenthesisNode -> MjParenthesisNode -> Ok
  | _ => Rerr.RerrTodo(`Argg, unhandled MathJsNode: ${node["type"]}`)-> Error
}

let rec show = (mjNode: mjNode): string => {
  let showValue = (a: 'a): string => if (Js.typeof(a) == "string") {
    `'${Js.String.make(a)}'`
  } else {
    Js.String.make(a)
  }

  let showNodeArray = (nodeArray: array<node>): string =>
    nodeArray
    -> Belt.Array.map( a => showResult(castNodeType(a)) )
    -> AE.interperse(", ")
    -> Js.String.concatMany("")

  let showFunctionNode = (fnode: functionNode): string =>
    `${fnode["fn"]}(${fnode["args"]->showNodeArray})`

  let showObjectEntry = ( (key: string, value: node) ): string =>
    `${key}: ${value->castNodeType->showResult}`

  let showObjectNode = (oNode: objectNode): string =>
    `{${  oNode["properties"]
          ->Js.Dict.entries
          ->Belt.Array.map(entry=>entry->showObjectEntry)
          ->AE.interperse(", ")->Js.String.concatMany("")
    }}`

  switch mjNode {
  | MjArrayNode(aNode) => `[${aNode["items"]->showNodeArray}]`
  | MjConstantNode(cNode) => cNode["value"]->showValue
  | MjObjectNode(oNode) => oNode -> showObjectNode
  | MjParenthesisNode(pNode) => `(${showResult(castNodeType(pNode["content"]))})`
  | MjFunctionNode(fNode) =>
      fNode -> showFunctionNode
  | MjOperatorNode(opNode) =>
      opNode -> castOperatorNodeToFunctionNode -> showFunctionNode
}}
and let showResult = (rmjnode: result<mjNode, reducerError>): string =>
switch rmjnode {
  | Error(e) => Rerr.showError(e)
  | Ok(mjNode) => show(mjNode)
}
