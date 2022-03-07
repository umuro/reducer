module LV = ReducerExternal_TreeValue

module Sample = { // In real life real libraries should be somewhere else
  /*
    For an example of mapping polymorphic custom functions
  */
  let customAdd = (a:float, b:float):float => {open Belt.Float; a + b}
}

/*
  Map external calls of Lisp Engine
*/
let rec dispatch = (call: LV.functionCall, chain): result<LV.treeValue, 'e> => switch call {

|  ("add", [LvNumber(a), LvNumber(b)]) =>  Sample.customAdd(a, b)  -> LvNumber -> Ok

|  call => chain(call)
}
