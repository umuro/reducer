module MathJsParse = Reducer_MathJsParse
module CodeTree = Reducer_CodeTree
module ListExt = Reducer_ListExt

module CTV = ReducerExternal_CodeTreeValue

let parse = (codeText:string):result<CodeTree.codeTree, 'e> => codeText -> CodeTree.parse
let eval = (codeText:string):result<CodeTree.codeTreeValue, 'e> => codeText -> CodeTree.eval


module Examples = {
  let examplesShow = ():unit => {
    Js.log("Reducer.CodeTree parse examples")

    Js.log("case 1")
    parse("1") ->  CodeTree.showResult -> Js.log
    Js.log("case (1)")
    parse("(1)") -> CodeTree.showResult -> Js.log
    Js.log("case 1+2")
    parse("1+2") -> CodeTree.showResult -> Js.log
    Js.log("case add(1,2)")
    parse("add(1,2)") -> CodeTree.showResult -> Js.log
    Js.log("case 1+2*3")
    parse("1+2*3") -> CodeTree.showResult -> Js.log
    ()
  }

  let examplesEval = ():unit =>  {
    Js.log("Reducer.CodeTree.eval examples")
    Js.log("case 1")
    eval("1") -> CTV.showResult -> Js.log
    Js.log("case 1+2")
    eval("1+2") -> CTV.showResult -> Js.log
    Js.log("case 1+(2+3)")
    eval("1+(2+3)") -> CTV.showResult -> Js.log
    ()
  }
  let examples = ():unit => {
    examplesShow()
    examplesEval()
    ()
  }
}
