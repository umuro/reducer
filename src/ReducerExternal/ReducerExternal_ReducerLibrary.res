module CT = ReducerExternal_TreeValue

module Sample = { // In real life real libraries should be somewhere else
  /*
    For an example of mapping polymorphic custom functions
  */
  let customAdd = (a:float, b:float):float => {open Belt.Float; a + b}
}

/*
  Map external calls of Reducer
*/
let rec dispatch = (call: CT.functionCall, chain): result<CT.treeValue, 'e> => switch call {

|  ("add", [TvNumber(a), TvNumber(b)]) =>  Sample.customAdd(a, b)  -> TvNumber -> Ok

|  call => chain(call)
}
