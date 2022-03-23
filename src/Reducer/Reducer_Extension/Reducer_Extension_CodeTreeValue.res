/*
  Irreducable values. Reducer does not know about those. Only used for external calls
  This is a configuration to to make external calls of those types
*/
module AE = Reducer_Extra_Array
module Rerr = Reducer_Error

type rec codeTreeValue =
| CtvBool(bool)
| CtvNumber(float)
| CtvString(string)
| CtvSymbol(string)
| CtvArray(array<codeTreeValue>)

type functionCall  = (string, array<codeTreeValue>)

let rec show = aValue => switch aValue {
  | CtvBool( aBool ) => Js.String.make( aBool )
  | CtvNumber( aNumber ) => Js.String.make( aNumber )
  | CtvString( aString ) => `'${aString}'`
  | CtvSymbol( aString ) => `:${aString}`
  | CtvArray( anArray ) => {
      let args = anArray
        -> Belt.Array.map(each => show(each))
        -> AE.interperse(", ")
        -> Js.String.concatMany("")
      `[${args}]`}
}

let showArgs = (args: array<codeTreeValue>): string => {
  args
  -> Belt.Array.map(arg => arg->show)
  -> AE.interperse(", ")
  -> Js.String.concatMany("") }

let showFunctionCall = ((fn, args)): string => `${fn}(${ showArgs(args) })`

let showResult = (x) => switch x {
  | Ok(a) => `Ok(${ show(a) })`
  | Error(m) => `Error(${Rerr.showError(m)})`
}
