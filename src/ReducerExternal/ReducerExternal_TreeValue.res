type treeValue =
| TvBool(bool)
| TvNumber(float)
| TvString(string)
| TvUndefined

type functionCall  = (string, array<treeValue>)

let show = aValue => switch aValue {
  | TvBool( aBool ) => Js.String.make( aBool )
  | TvNumber( aNumber ) => Js.String.make( aNumber )
  | TvString( aString ) => "\"" ++ aString++ "\""
  | TvUndefined => "Undefined"
}

let showResult = (x) => switch x {
  | Ok(a) => "Ok("++ show(a)++")"
  | Error(m) => "Error("++ Js.String.make(m) ++")"
}
