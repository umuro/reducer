module BuiltIn = Reducer_Dispatch_BuiltIn
module T = Reducer_CodeTree_T
module CTV = Reducer_Extension.CodeTreeValue
module MJ = Reducer_MathJs_Parse
module MJT = Reducer_MathJs_ToCodeTree
module RLE = Reducer_ListExt
module Rerr = Reducer_Error
module Result = Belt.Result

type codeTree = T.codeTree
type codeTreeValue = CTV.codeTreeValue
type reducerError = Rerr.reducerError

/*
  Shows the Lisp Code as text lisp code
*/
let rec show = codeTree => switch codeTree {
| T.CtList(aList) => "("
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
let parse_ = (expr: string, parser, converter): result<codeTree, reducerError> =>
  expr -> parser -> Result.flatMap(node => converter(node))

let parse = (mathJsCode: string): result<codeTree, reducerError> =>
  mathJsCode -> parse_( MJ.parse, MJT.fromNode )

module MapString = Belt.Map.String
type bindings = MapString.t<unit>
let defaultBindings: bindings = MapString.fromArray([])
// TODO Define bindings for function execution context

let execFunctionCall = ( lisp: list<codeTree>, _bindings ): result<codeTree, 'e> => {

  let stripArgs = (args): list<codeTreeValue> =>
    Belt.List.map(args, a =>
      switch a {
        | T.CtValue(aValue) => aValue
        | _ => CTV.CtvUndefined
      })

  if Js.List.isEmpty( lisp ) {
    Rerr.RerrTodo("Got nothing")->Error
  } else {
    switch List.hd( lisp ) {
    | CtSymbol(fname) => {
        let aCall = (fname, List.tl(lisp)->stripArgs->Belt.List.toArray )
        // Ok(CtValue(CTV.CtvString("result_of_fname")))
        Result.map( BuiltIn.dispatch(aCall), aValue => T.CtValue(aValue))
      }
    | _ => Rerr.RerrTodo("User space functions not yet allowed")->Error
    }
  }

}

let rec execCodeTree = (aCodeTree, bindings): result<codeTree, 'e> => switch aCodeTree {
  | T.CtList( aList ) => execLispList( aList, bindings )
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
