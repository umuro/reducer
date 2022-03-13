module Ctv = ReducerExternal.CodeTreeValue
module Lib = ReducerExternal.ReducerLibrary
module Rerr = Reducer_Error
module ME = Reducer_MathJsEval
/*
  MathJs provides default implementations for external calls
*/
exception TestRescriptException

let callMatjJs = (call: Ctv.functionCall): result<'b, Rerr.reducerError> =>
  switch call {
    | ("jsraise", [msg]) => Js.Exn.raiseError(Ctv.show(msg)) // For Tests
    | ("resraise", _) => raise(TestRescriptException) // For Tests
    | call => call->Ctv.showFunctionCall-> ME.eval
  }

/*
  Lisp engine uses Result monad while reducing expressions
*/
let dispatch = (call: Ctv.functionCall): result<Ctv.codeTreeValue, Rerr.reducerError> =>
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
