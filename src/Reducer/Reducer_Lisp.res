module LV = ReducerExternal.LispValue
module BuiltIn = Reducer_BuiltIn
module RLE = Reducer_ListExt
module Dbg = Reducer_Debug

module Result = Belt.Result

type lispValue = LV.lispValue

type rec lispCode =
| LcList(listOfLispCode)  // A list to map-reduce
| LcValue(lispValue)      // Irreducable built-in value
| LcSymbol(string)        // A symbol. Defined in local bindings
and listOfLispCode = list<lispCode>
type resultOfLispCode<'e> = result<lispCode, 'e>
type resultOfListOfLispCode<'e> = result<listOfLispCode, 'e>

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
let rec fromNode = (node: MJ.node): resultOfLispCode<'e> => switch node["type"] {
| "ConstantNode" => switch node -> MJ.castConstantNode -> MJ.constantNodeValue {
  | MJ.ExnNumber(x) => x -> LV.LvNumber -> LcValue -> Ok
  | MJ.ExnString(x) => x -> LV.LvString -> LcValue -> Ok
  | MJ.ExnBool(x) => x -> LV.LvBool -> LcValue -> Ok
  | MJ.ExnUnknown => "Unhandled MathJs constantNode value" -> Error
  }
| "FunctionNode" => {
    let fNode = node -> MJ.castFunctionNode
    let lispName = fNode["fn"] -> LcSymbol
    let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
    lispArgs
    -> Result.map( aList => list{lispName, ...aList} -> LcList )
  }
| "OperatorNode" => {
  let fNode = node -> MJ.castOperatorNode
  let lispName = fNode["fn"] -> LcSymbol
  let lispArgs = fNode["args"] -> Belt.List.fromArray -> fromNodeList
  lispArgs
  -> Result.map( aList => list{lispName, ...aList} -> LcList )
}
| "ParenthesisNode" => {
  let pNode = node -> MJ.castParanthesisNode
  pNode["content"] -> fromNode
}

| aNodeType => Error("TODO MathJs Node Type: " ++ aNodeType)
}
and let fromNodeList = (nodeList: list<MJ.node>): resultOfListOfLispCode <'e> =>
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
let rec show = lispCode => switch lispCode {
| LcList(aList) => "("
  ++ (Belt.List.map(aList, aValue => show(aValue))
    -> RLE.interperse(" ")
    -> Belt.List.toArray -> Js.String.concatMany(""))
  ++ ")"
| LcSymbol(aSymbol) => ":" ++ aSymbol
| LcValue(aValue) => LV.show(aValue)
}

let showResult = (codeResult) => switch codeResult {
| Ok(a) => "Ok("++ show(a) ++")"
| Error(m) => "Error("++ Js.String.make(m) ++")"
}

/*
  Converts a MathJs code to Lisp Code
*/
let parse = (mathJsCode: string): resultOfLispCode<'e> =>
  mathJsCode -> MJ.parse -> Result.flatMap(node => fromNode(node))


module MapString = Belt.Map.String
type bindings = MapString.t<unit>
let defaultBindings: bindings = MapString.fromArray([])
// TODO Define bindings for function execution context

let execFunctionCall = ( lisp: listOfLispCode, _bindings ): result<lispCode, 'e> => {

  let stripArgs = (args): list<LV.lispValue> =>
    Belt.List.map(args, a =>
      switch a {
        | LcValue(aValue) => aValue
        | _ => LV.LvUndefined
      })

  if Js.List.isEmpty( lisp ) {
    Error("Function expected; got nothing")
  } else {
    switch List.hd( lisp ) {
    | LcSymbol(fname) => {
        let aCall = (fname, List.tl(lisp)->stripArgs->Belt.List.toArray )
        // Ok(LcValue(LV.LvString("result_of_fname")))
        Result.map( BuiltIn.dispatch(aCall), aValue => LcValue(aValue))
      }
    | _ => Error("TODO User space functions not yet allowed")
    }
  }

}

let rec execLispCode = (aLispCode, bindings): result<lispCode, 'e> => switch aLispCode {
  | LcList( aList ) => execLispList( aList, bindings )
  | x => x -> Ok
}
and let execLispList = ( list: listOfLispCode, bindings ) => {
  Belt.List.reduce(list, Ok(list{}), (racc, currCode) =>
  racc
    -> Result.flatMap( acc =>
      execLispCode(currCode, bindings)
        -> Result.map(newCode => list{newCode, ...acc}
        )
    )
  )
  -> Result.map(aList => Belt.List.reverse(aList))
  -> Result.flatMap(aList => execFunctionCall(aList, bindings))
}

let evalWBindingsLispCode = (aLispCode, bindings): result<lispValue, 'e> =>
  Result.flatMap( execLispCode(aLispCode, bindings),
  aCode => switch aCode {
    | LcValue( aValue ) => aValue -> Ok
    | other => ("Unexecuted code remaining: "++ show(other)) -> Error
  }
)

/*
  Evaluates MathJs code via Lisp using bindings and answers the result
*/
let evalWBindings = (codeText:string, bindings: bindings) => {
  parse(codeText) -> Result.flatMap(code => code -> evalWBindingsLispCode(bindings))
}

/*
  Evaluates MathJs code via Lisp and answers the result
*/
let eval = (code: string) => evalWBindings(code, defaultBindings)
