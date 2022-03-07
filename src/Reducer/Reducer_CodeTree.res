module TV = ReducerExternal.TreeValue
module BuiltIn = Reducer_BuiltIn
module RLE = Reducer_ListExt
module Dbg = Reducer_Debug

module Result = Belt.Result

type treeValue = TV.treeValue

type rec codeTree =
| CtList(listOfCodeTree)  // A list to map-reduce
| CtValue(treeValue)      // Irreducable built-in value
| CtSymbol(string)        // A symbol. Defined in local bindings
and listOfCodeTree = list<codeTree>
type resultOfCodeTree<'e> = result<codeTree, 'e>
type resultOfListOfCodeTree<'e> = result<listOfCodeTree, 'e>

module MJ = Reducer_MathJsParse

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
let rec fromNode = (node: MJ.node): resultOfCodeTree<'e> => switch node["type"] {
| "ConstantNode" => switch node -> MJ.castConstantNode -> MJ.constantNodeValue {
  | MJ.ExnNumber(x) => x -> TV.TvNumber -> CtValue -> Ok
  | MJ.ExnString(x) => x -> TV.TvString -> CtValue -> Ok
  | MJ.ExnBool(x) => x -> TV.TvBool -> CtValue -> Ok
  | MJ.ExnUnknown => "Unhandled MathJs constantNode value" -> Error
  }
| "FunctionNode" => {
    let fNode = node -> MJ.castFunctionNode
    let lispName = fNode["fn"] -> CtSymbol
    let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
    lispArgs
    -> Result.map( aList => list{lispName, ...aList} -> CtList )
  }
| "OperatorNode" => {
  let fNode = node -> MJ.castOperatorNode
  let lispName = fNode["fn"] -> CtSymbol
  let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
  lispArgs
  -> Result.map( aList => list{lispName, ...aList} -> CtList )
}
| "ParenthesisNode" => {
  let pNode = node -> MJ.castParanthesisNode
  pNode["content"] -> fromNode
}

| aNodeType => Error("TODO MathJs Node Type: " ++ aNodeType)
}
and let fromNodeList = (nodeList: list<MJ.node>): resultOfListOfCodeTree <'e> =>
  Belt.List.reduce(nodeList, Ok(list{}), (racc, currNode) =>
    racc
      -> Result.flatMap( acc =>
        fromNode(currNode)
          -> Result.map(newCode => list{newCode, ...acc}
          )
      )
  ) -> Result.map(aList => Belt.List.reverse(aList))

/*
  Shows the Lisp Code as text lisp code
*/
let rec show = codeTree => switch codeTree {
| CtList(aList) => "("
  ++ (Belt.List.map(aList, aValue => show(aValue))
    -> RLE.interperse(" ")
    -> Belt.List.toArray -> Js.String.concatMany(""))
  ++ ")"
| CtSymbol(aSymbol) => ":" ++ aSymbol
| CtValue(aValue) => TV.show(aValue)
}

let showResult = (codeResult) => switch codeResult {
| Ok(a) => "Ok("++ show(a) ++")"
| Error(m) => "Error("++ Js.String.make(m) ++")"
}

/*
  Converts a MathJs code to Lisp Code
*/
let parse = (mathJsCode: string): resultOfCodeTree<'e> =>
  mathJsCode -> MJ.parse -> Result.flatMap(node => fromNode(node))


module MapString = Belt.Map.String
type bindings = MapString.t<unit>
let defaultBindings: bindings = MapString.fromArray([])
// TODO Define bindings for function execution context

let execFunctionCall = ( lisp: listOfCodeTree, _bindings ): result<codeTree, 'e> => {

  let stripArgs = (args): list<TV.treeValue> =>
    Belt.List.map(args, a =>
      switch a {
        | CtValue(aValue) => aValue
        | _ => TV.TvUndefined
      })

  if Js.List.isEmpty( lisp ) {
    Error("Function expected; got nothing")
  } else {
    switch List.hd( lisp ) {
    | CtSymbol(fname) => {
        let aCall = (fname, List.tl(lisp)->stripArgs->Belt.List.toArray )
        // Ok(CtValue(TV.TvString("result_of_fname")))
        Result.map( BuiltIn.dispatch(aCall), aValue => CtValue(aValue))
      }
    | _ => Error("TODO User space functions not yet allowed")
    }
  }

}

let rec execCodeTree = (aCodeTree, bindings): result<codeTree, 'e> => switch aCodeTree {
  | CtList( aList ) => execLispList( aList, bindings )
  | x => x -> Ok
}
and let execLispList = ( list: listOfCodeTree, bindings ) => {
  Belt.List.reduce(list, Ok(list{}), (racc, currCode) =>
  racc
    -> Result.flatMap( acc =>
      execCodeTree(currCode, bindings)
        -> Result.map(newCode => list{newCode, ...acc}
        )
    )
  )
  -> Result.map(aList => Belt.List.reverse(aList))
  -> Result.flatMap(aList => execFunctionCall(aList, bindings))
}

let evalWBindingsCodeTree = (aCodeTree, bindings): result<treeValue, 'e> =>
  Result.flatMap( execCodeTree(aCodeTree, bindings),
  aCode => switch aCode {
    | CtValue( aValue ) => aValue -> Ok
    | other => ("Unexecuted code remaining: "++ show(other)) -> Error
  }
)

/*
  Evaluates MathJs code via Lisp using bindings and answers the result
*/
let evalWBindings = (codeText:string, bindings: bindings) => {
  parse(codeText) -> Result.flatMap(code => code -> evalWBindingsCodeTree(bindings))
}

/*
  Evaluates MathJs code via Lisp and answers the result
*/
let eval = (code: string) => evalWBindings(code, defaultBindings)
