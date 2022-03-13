module CTV = Reducer_Extension.CodeTreeValue
module Rerr = Reducer_Error

external castBool: unit => bool = "%identity"
external castNumber: unit => float = "%identity"
external castString: unit => string = "%identity"

/*
  As JavaScript returns us any type, we need to type check and cast type propertype before using it
*/
let jsToCtv = (jsValue): result<CTV.codeTreeValue, Rerr.reducerError> => {
  let typeString = %raw(`typeof jsValue`)
  switch typeString {
  | "boolean" => jsValue -> castBool -> CTV.CtvBool -> Ok
  | "number" => jsValue -> castNumber -> CTV.CtvNumber -> Ok
  | "string" => jsValue -> castString -> CTV.CtvString -> Ok
  | other => Rerr.RerrTodo("Unhandled MathJs type: "++Js.String.make(other)) -> Error
  }
}
