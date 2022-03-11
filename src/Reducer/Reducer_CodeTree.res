module CTV = ReducerExternal.CodeTreeValue
module BuiltIn = Reducer_BuiltIn
module RLE = Reducer_ListExt
module Dbg = Reducer_Debug
module Rerr = Reducer_Error

module Result = Belt.Result

type codeTreeValue = CTV.codeTreeValue

type rec codeTree =
| CtList(list<codeTree>)  // A list to map-reduce
| CtValue(codeTreeValue)      // Irreducable built-in value. Reducer should not know the internals
| CtSymbol(string)        // A symbol. Defined in local bindings

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
let rec fromNode =
  (mjnode: MJ.node): result<codeTree, Rerr.reducerError> =>
    switch MJ.castNodeType(mjnode) {
      | Ok(MjConstantNode(cNode)) => switch MJ.constantNodeValue(cNode) {
        | MJ.ExnNumber(x) => x -> CTV.CtvNumber -> CtValue -> Ok
        | MJ.ExnString(x) => x -> CTV.CtvString -> CtValue -> Ok
        | MJ.ExnBool(x) => x -> CTV.CtvBool -> CtValue -> Ok
        | MJ.ExnUnknown(x) => RerrTodo("Unhandled MathJs constantNode type: "++x) -> Error
        }
      | Ok(MjFunctionNode(fNode)) => {
        let lispName = fNode["fn"] -> CtSymbol
        let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
        lispArgs
        -> Result.map( aList => list{lispName, ...aList} -> CtList )
        }
      | Ok(MjOperatorNode(fNode)) => {
        let lispName = fNode["fn"] -> CtSymbol
        let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
        lispArgs
        -> Result.map( aList => list{lispName, ...aList} -> CtList )
        }
      | Ok(MjParanthesisNode(pNode)) => pNode["content"] -> fromNode
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
| CtValue(aValue) => CTV.show(aValue)
}

let showResult = (codeResult) => switch codeResult {
| Ok(a) => "Ok("++ show(a) ++")"
| Error(m) => "Error("++ Js.String.make(m) ++")"
}

/*
  Converts a MathJs code to Lisp Code
*/
let parse = (mathJsCode: string): result<codeTree, Rerr.reducerError> =>
  mathJsCode -> MJ.parse -> Result.flatMap(node => fromNode(node))

module MapString = Belt.Map.String
type bindings = MapString.t<unit>
let defaultBindings: bindings = MapString.fromArray([])
// TODO Define bindings for function execution context

let execFunctionCall = ( lisp: list<codeTree>, _bindings ): result<codeTree, 'e> => {

  let stripArgs = (args): list<CTV.codeTreeValue> =>
    Belt.List.map(args, a =>
      switch a {
        | CtValue(aValue) => aValue
        | _ => CTV.CtvUndefined
      })

  if Js.List.isEmpty( lisp ) {
    Rerr.RerrTodo("Got nothing")->Error
  } else {
    switch List.hd( lisp ) {
    | CtSymbol(fname) => {
        let aCall = (fname, List.tl(lisp)->stripArgs->Belt.List.toArray )
        // Ok(CtValue(CTV.CtvString("result_of_fname")))
        Result.map( BuiltIn.dispatch(aCall), aValue => CtValue(aValue))
      }
    | _ => Rerr.RerrTodo("User space functions not yet allowed")->Error
    }
  }

}

let rec execCodeTree = (aCodeTree, bindings): result<codeTree, 'e> => switch aCodeTree {
  | CtList( aList ) => execLispList( aList, bindings )
  | x => x -> Ok
}
and let execLispList = ( list: list<codeTree>, bindings ) => {
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

let evalWBindingsCodeTree = (aCodeTree, bindings): result<codeTreeValue, 'e> =>
  Result.flatMap( execCodeTree(aCodeTree, bindings),
  aCode => switch aCode {
    | CtValue( aValue ) => aValue -> Ok
    | other => RerrUnexecutedCode(show(other)) -> Error
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
