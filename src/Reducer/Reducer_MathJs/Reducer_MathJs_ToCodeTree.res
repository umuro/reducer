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
    MJ.castNodeType(mjnode) -> Result.flatMap(typedMjNode => {

      let fromNodeList = (nodeList: list<MJ.node>): result<list<codeTree>, 'e> =>
        Belt.List.reduceReverse(nodeList, Ok(list{}), (racc, currNode) =>
          racc
            -> Result.flatMap( acc =>
              fromNode(currNode)
                -> Result.map(newCode => list{newCode, ...acc})))

      let caseFunctionNode = (fNode) => {
        let lispName = fNode["fn"] -> CTV.CtvSymbol -> CTT.CtValue
        let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
        lispArgs
        -> Result.map( aList => list{lispName, ...aList} -> CTT.CtList )
      }

      let caseAccessorNode = ( objectNode, index ) => {
        let lispName = "internalAtRecordIndex" -> CTV.CtvSymbol -> CTT.CtValue
        let lispIndex = index  -> CTV.CtvSymbol -> CTT.CtValue
        fromNode( objectNode )
          -> Result.map( newCode => list{lispName, newCode, lispIndex}
                                    -> CTT.CtList )
      }

      let caseObjectNode = oNode => {

        let fromObjectEntries = ( entryList ) => {
          let rargs = Belt.List.reduceReverse(
                          entryList,
                          Ok(list{}),
                          (racc, (key: string, value: MJ.node))
                          =>
            racc
              -> Result.flatMap( acc =>
                    fromNode(value) -> Result.map(valueCodeTree => {
                      let entryCode = list{key->CTV.CtvString->CTT.CtValue, valueCodeTree}
                        -> CTT.CtList
                      list{entryCode, ...acc}})))
          let lispName = "internalConstructRecord" -> CTV.CtvSymbol -> CTT.CtValue
          rargs -> Result.map(args => list{lispName, CTT.CtList(args)} -> CTT.CtList)
        }

        oNode["properties"]
        -> Js.Dict.entries
        -> Belt.List.fromArray
        -> fromObjectEntries
      }

      switch typedMjNode {
        | MjArrayNode(aNode) =>
            aNode["items"]
            -> Belt.List.fromArray
            -> fromNodeList
            -> Result.map(list => CTT.CtList(list))
        | MjConstantNode(cNode) =>
            cNode["value"]-> JsG.jsToCtv -> Result.map( v => v->CTT.CtValue)
        | MjFunctionNode(fNode) => fNode
            -> caseFunctionNode
        | MjOperatorNode(opNode) => opNode
            ->  MJ.castOperatorNodeToFunctionNode  -> caseFunctionNode
        | MjParenthesisNode(pNode) => pNode["content"] -> fromNode
        | MjAccessorNode(aNode) => caseAccessorNode(aNode["object"], aNode["index"])
        | MjObjectNode(oNode) => caseObjectNode(oNode)
        | MjSymbolNode(sNode) =>
            sNode["name"]-> CTV.CtvSymbol -> CTT.CtValue -> Ok
      }})
