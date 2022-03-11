module CTV = ReducerExternal.CodeTreeValue
module Lib = ReducerExternal.ReducerLibrary
module Rerr = Reducer_Error
/*
  MathJs provides default implementations for external calls
*/
let callMatjJs = (_functionCall): result<'b, Rerr.reducerError> =>
  RerrTodo("Calling MathJs")->Error // TODO call MathJs by default

/*
  Lisp engine uses Result monad while reducing expressions
*/
let dispatch = (call: CTV.functionCall): result<CTV.codeTreeValue, Rerr.reducerError> =>
  try {
    Lib.dispatch(call, callMatjJs)
  } catch {
  | Js.Exn.Error(obj) =>
    RerrJs(Js.Exn.message(obj), Js.Exn.name(obj))->Error
  }
