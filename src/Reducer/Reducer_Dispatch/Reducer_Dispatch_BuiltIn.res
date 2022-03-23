module CTV = Reducer_Extension.CodeTreeValue
module Lib = Reducer_Extension.ReducerLibrary
module ME = Reducer_MathJs.Eval
module Rerr = Reducer_Error
/*
  MathJs provides default implementations for builtins
  This is where all the expected builtins like + = * / sin cos log ln etc are handled
  DO NOT try to add external function mapping here!
*/
type codeTreeValue = CTV.codeTreeValue
type reducerError = Rerr.reducerError

exception TestRescriptException

let callMatjJs = (call: CTV.functionCall): result<'b, reducerError> =>
  switch call {
    | ("jsraise", [msg]) => Js.Exn.raiseError(CTV.show(msg)) // For Tests
    | ("resraise", _) => raise(TestRescriptException) // For Tests
    | call => call->CTV.showFunctionCall-> ME.eval
  }

/*
  Lisp engine uses Result monad while reducing expressions
*/
let dispatch = (call: CTV.functionCall): result<codeTreeValue, reducerError> =>
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
