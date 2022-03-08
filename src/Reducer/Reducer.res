module MathJsParse = Reducer_MathJsParse
module CodeTree = Reducer_CodeTree
module ListExt = Reducer_ListExt

module CTV = ReducerExternal_CodeTreeValue

let parse = (codeText:string):result<CodeTree.codeTree, 'e> => codeText -> CodeTree.parse
let eval = (codeText:string):result<CodeTree.codeTreeValue, 'e> => codeText -> CodeTree.eval
