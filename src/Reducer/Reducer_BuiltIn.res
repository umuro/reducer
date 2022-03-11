module CTV = ReducerExternal.CodeTreeValue
module Lib = ReducerExternal.ReducerLibrary
module Rerr = Reducer_Error
/*
  MathJs provides default implementations for external calls
*/
exception TestRescriptException

let callMatjJs = (call: CTV.functionCall): result<'b, Rerr.reducerError> =>
  switch call {
    | ("jsraise", [msg]) => Js.Exn.raiseError(CTV.show(msg))
    | ("resraise", _) => raise(TestRescriptException)
    | (fn, args) => RerrFunctionNotFound(fn, CTV.showArgs(args)) -> Error
  }

/*
  Lisp engine uses Result monad while reducing expressions
*/
let dispatch = (call: CTV.functionCall): result<CTV.codeTreeValue, Rerr.reducerError> =>
  try {
    let (fn, args) = call
    // There is a bug that prevents string match in patterns
    // So we have to recreate a copy of the string
    Lib.dispatch((Js.String.make(fn), args), callMatjJs)
  } catch {
  | Js.Exn.Error(obj) =>
    RerrJs(Js.Exn.message(obj), Js.Exn.name(obj))->Error
  | _ => RerrTodo("unhandled rescript exception")->Error
  }
