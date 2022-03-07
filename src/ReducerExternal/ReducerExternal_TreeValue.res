type treeValue =
| LvBool(bool)
| LvNumber(float)
| LvString(string)
| LvUndefined

type functionCall  = (string, array<treeValue>)

let show = aValue => switch aValue {
  | LvBool( aBool ) => Js.String.make( aBool )
  | LvNumber( aNumber ) => Js.String.make( aNumber )
  | LvString( aString ) => "\"" ++ aString++ "\""
  | LvUndefined => "Undefined"
}

let showResult = (x) => switch x {
  | Ok(a) => "Ok("++ show(a)++")"
  | Error(m) => "Error("++ Js.String.make(m) ++")"
}
