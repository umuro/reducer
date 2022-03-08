module CTV = ReducerExternal_CodeTreeValue

module Sample = { // In real life real libraries should be somewhere else
  /*
    For an example of mapping polymorphic custom functions
  */
  let customAdd = (a:float, b:float):float => {a +. b}
}

/*
  Map external calls of Reducer
*/
let dispatch = (call: CTV.functionCall, chain): result<CTV.codeTreeValue, 'e> => switch call {

|  ("add", [CtvNumber(a), CtvNumber(b)]) =>  Sample.customAdd(a, b)  -> CtvNumber -> Ok

|  call => chain(call)
}
