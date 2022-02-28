module LV = ReducerExternal.LispValue
module Lib = ReducerExternal.LispLibrary
/*
  MathJs provides default implementations for external calls
*/
let callMatjJs = (_functionCall) =>
  Error("TODO call MathJs") // TODO call MathJs by default

/*
  Lisp engine uses Result monad while reducing expressions
*/
let dispatch = (call: LV.functionCall): result<LV.lispValue, 'e> =>
  try {
    Lib.dispatch(call, callMatjJs)
  } catch {
  | Js.Exn.Error(obj) =>
    switch Js.Exn.message(obj) {
    | Some(m) => Error("RunTime Error "++m) //e.g. division by zero
    | None => Error("RunTime Error ")
    }
  }
