/*
  Irreducable values. Reducer does not know about those. Only used for external calls
  This is a configuration to to make external calls of those types
*/
module Rerr = Reducer_Error
module BA = Belt.Array

type codeTreeValue =
| CtvBool(bool)
| CtvNumber(float)
| CtvString(string)
| CtvUndefined

type functionCall  = (string, array<codeTreeValue>)

let show = aValue => switch aValue {
  | CtvBool( aBool ) => Js.String.make( aBool )
  | CtvNumber( aNumber ) => Js.String.make( aNumber )
  | CtvString( aString ) => "\"" ++ aString++ "\""
  | CtvUndefined => "Undefined"
}

let showArgs = args => BA.reduce(args, "", (acc, arg) => acc ++ " " ++ show(arg))

let showResult = (x) => switch x {
  | Ok(a) => "Ok("++ show(a)++")"
  | Error(m) => "Error("++ Rerr.showError(m) ++")"
}
