module MathJsParse = Reducer_MathJsParse
module Lisp = Reducer_Lisp
module ListExt = Reducer_ListExt

module LV = ReducerExternal_LispValue

let parse = (codeText:string):result<Lisp.lispCode, 'e> => codeText -> Lisp.parse
let eval = (codeText:string):result<Lisp.lispValue, 'e> => codeText -> Lisp.eval


module Examples = {
  let examplesShow = ():unit => {
    Js.log("Reducer.Lisp parse examples")

    Js.log("case 1")
    parse("1") ->  Lisp.showResult -> Js.log
    Js.log("case (1)")
    parse("(1)") -> Lisp.showResult -> Js.log
    Js.log("case 1+2")
    parse("1+2") -> Lisp.showResult -> Js.log
    Js.log("case add(1,2)")
    parse("add(1,2)") -> Lisp.showResult -> Js.log
    Js.log("case 1+2*3")
    parse("1+2*3") -> Lisp.showResult -> Js.log
    ()
  }

  let examplesEval = ():unit =>  {
    Js.log("Reducer.Lisp.eval examples")
    Js.log("case 1")
    eval("1") -> LV.showResult -> Js.log
    Js.log("case 1+2")
    eval("1+2") -> LV.showResult -> Js.log
    Js.log("case 1+(2+3)")
    eval("1+(2+3)") -> LV.showResult -> Js.log
    ()
  }
  let examples = ():unit => {
    examplesShow()
    examplesEval()
    ()
  }
}
