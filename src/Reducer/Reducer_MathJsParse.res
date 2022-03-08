/*
  MathJs Nodes
*/
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
external castNumber: unit => float = "%identity"
external castString: unit => string = "%identity"
external castBool: unit => bool = "%identity"

type exnConstant = ExnNumber(float) | ExnString(string) | ExnBool(bool) | ExnUnknown

/*
  As JavaScript returns us any type, we need to type check and cast type propertype before using it
*/
let constantNodeValue = (cnode: constantNode): exnConstant => {
  let typeString = %raw(`typeof cnode.value`)
  switch typeString {
  | "number" => cnode["value"] -> castNumber -> ExnNumber
  | "string" => cnode["value"] -> castString -> ExnString
  | "boolean" => cnode["value"] -> castBool -> ExnBool
  | _ => ExnUnknown
  }
}

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

//paranthesisNode
type paranthesisNode = {
  ...node,
  "content": node
}
external castParanthesisNode: node => paranthesisNode = "%identity"

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

module Examples = {
  let examples = ():unit => {
    Js.log("MathJs.parse Examples:")

    Js.log("case 1+2")
    switch parse("1+2") {
    | Ok(node) => node["type"]->Js.log
    | Error(m) => Rerr.showError(m)->Js.log
    }

    Js.log("case 1")
    switch parse("1") {
    | Ok(node) => {
        node["type"]->Js.log
        node -> castConstantNode -> constantNodeValue -> Js.log
      }
    | Error(m) => Rerr.showError(m)->Js.log
    }

    Js.log("case 'hello'")
    switch parse("'hello'") {
    | Ok(node) => {
        node["type"]->Js.log
        Js.log(node -> castConstantNode -> constantNodeValue)
      }
    | Error(m) => Rerr.showError(m)->Js.log
    }

    Js.log("case (1+2)")
    switch parse("(1+2)") {
    | Ok(node) => node["type"]->Js.log
    | Error(m) => Rerr.showError(m)->Js.log
    }

    Js.log("case (1)")
    switch parse("(1)") {
    | Ok(node) => Js.log(node["type"])
    | Error(m) => Rerr.showError(m)->Js.log
    }

    Js.log("case fn(1)")
    switch parse("fn(1)") {
    | Ok(node) => node["type"]->Js.log
    | Error(m) => Rerr.showError(m)->Js.log
    }

    ()
  }
}
