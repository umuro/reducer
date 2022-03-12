module CTV = ReducerExternal.CodeTreeValue
module Rerr = Reducer_Error

external castNumber: unit => float = "%identity"
external castString: unit => string = "%identity"
external castBool: unit => bool = "%identity"

/*
  As JavaScript returns us any type, we need to type check and cast type propertype before using it
*/
let jsToCtv = (jsValue): result<CTV.codeTreeValue, Rerr.reducerError> => {
  let typeString = %raw(`typeof jsValue`)
  switch typeString {
  | "number" => jsValue -> castNumber -> CTV.CtvNumber -> Ok
  | "string" => jsValue -> castString -> CTV.CtvString -> Ok
  | "boolean" => jsValue -> castBool -> CTV.CtvBool -> Ok
  | other => Rerr.RerrTodo("Unhandled MathJs type: "++Js.String.make(other)) -> Error
  }
}
