/*
  MathJs Nodes
  We make MathJs Nodes strong-typed
*/
module AE = Reducer_Extra_Array
module JsG = Reducer_Js_Gate
module Rerr = Reducer_Error

type reducerError = Rerr.reducerError

type rec node = {
  "type": string,
  "isNode": bool,
  "comment": string
}
type arrayNode = {
  ...node,
  "items": array<node>
}
//assignmentNode
//blockNode
//conditionalNode
type constantNode = {
  ...node,
  "value": unit
}
//functionAssignmentNode
type functionNode = {
  ...node,
  "fn": string,
  "args": array<node>
}
//indexNode
type objectNode = {
  ...node,
  "properties": Js.Dict.t<node>
}
type accessorNode = {
  ...node,
  "object": node,
  "index": string
}
type operatorNode = {
  ...functionNode,
  "op": string,
}

//parenthesisNode
type parenthesisNode = {
  ...node,
  "content": node
}
//rangeNode
//relationalNode
//symbolNode

external castAccessorNode: node => accessorNode = "%identity"
external castArrayNode: node => arrayNode = "%identity"
external castConstantNode: node => constantNode = "%identity"
external castFunctionNode: node => functionNode = "%identity"
external castObjectNode: node => objectNode = "%identity"
external castOperatorNode: node => operatorNode = "%identity"
external castOperatorNodeToFunctionNode: operatorNode => functionNode = "%identity"
external castParenthesisNode: node => parenthesisNode = "%identity"

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
  | MjAccessorNode(accessorNode)
  | MjArrayNode(arrayNode)
  | MjConstantNode(constantNode)
  | MjFunctionNode(functionNode)
  | MjObjectNode(objectNode)
  | MjOperatorNode(operatorNode)
  | MjParenthesisNode(parenthesisNode)

let castNodeType = (node: node) => switch node["type"] {
  | "AccessorNode" => node -> castAccessorNode -> MjAccessorNode -> Ok
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
    -> Belt.Array.map( a => showMathJsNode(a) )
    -> AE.interperse(", ")
    -> Js.String.concatMany("")

  let showFunctionNode = (fnode: functionNode): string =>
    `${fnode["fn"]}(${fnode["args"]->showNodeArray})`

  let showObjectEntry = ( (key: string, value: node) ): string =>
    `${key}: ${value->showMathJsNode}`

  let showObjectNode = (oNode: objectNode): string =>
    `{${  oNode["properties"]
          ->Js.Dict.entries
          ->Belt.Array.map(entry=>entry->showObjectEntry)
          ->AE.interperse(", ")->Js.String.concatMany("")
    }}`

  switch mjNode {
  | MjAccessorNode(aNode) => `${aNode["object"]->showMathJsNode}.${aNode["index"]}`
  | MjArrayNode(aNode) => `[${aNode["items"]->showNodeArray}]`
  | MjConstantNode(cNode) => cNode["value"]->showValue
  | MjObjectNode(oNode) => oNode -> showObjectNode
  | MjParenthesisNode(pNode) => `(${showMathJsNode(pNode["content"])})`
  | MjFunctionNode(fNode) => fNode -> showFunctionNode
  | MjOperatorNode(opNode) => opNode -> castOperatorNodeToFunctionNode -> showFunctionNode
}}
and let showResult = (rmjnode: result<mjNode, reducerError>): string =>
  switch rmjnode {
    | Error(e) => Rerr.showError(e)
    | Ok(mjNode) => show(mjNode)
  }
and let showMathJsNode = (node) => node -> castNodeType -> showResult
