module CTT = Reducer_CodeTree_T
module CTV = Reducer_Extension.CodeTreeValue
module JsG = Reducer_Js_Gate
module MJ = Reducer_MathJs_Parse
module Rerr = Reducer_Error
module Result = Belt.Result

type codeTree = CTT.codeTree
type codeTreeValue = CTV.codeTreeValue
type reducerError = Rerr.reducerError

// TODO:
// AccessorNode
// ArrayNode
// AssignmentNode
// BlockNode
// ConditionalNode
// FunctionAssignmentNode
// IndexNode
// ObjectNode
// RangeNode
// RelationalNode
// SymbolNode
let rec fromNode =
  (mjnode: MJ.node): result<codeTree, reducerError> =>
    switch MJ.castNodeType(mjnode) {
      | Ok(MjConstantNode(cNode)) =>
        cNode["value"]-> JsG.jsToCtv -> Result.map( v => v->CTT.CtValue)
      | Ok(MjFunctionNode(fNode)) => {
        let lispName = fNode["fn"] -> CTT.CtSymbol
        let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
        lispArgs
        -> Result.map( aList => list{lispName, ...aList} -> CTT.CtList )
        }
      | Ok(MjOperatorNode(fNode)) => {
        let lispName = fNode["fn"] -> CTT.CtSymbol
        let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
        lispArgs
        -> Result.map( aList => list{lispName, ...aList} -> CTT.CtList )
        }
      | Ok(MjParenthesisNode(pNode)) => pNode["content"] -> fromNode
      | Error(x) => Error(x)
    }
and let fromNodeList = (nodeList: list<MJ.node>): result<list<codeTree>, 'e> =>
  Belt.List.reduce(nodeList, Ok(list{}), (racc, currNode) =>
    racc
      -> Result.flatMap( acc =>
        fromNode(currNode)
          -> Result.map(newCode => list{newCode, ...acc}
          )
      )
  ) -> Result.map(aList => Belt.List.reverse(aList))
