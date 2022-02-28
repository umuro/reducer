// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Reducer_Lisp = require("./Reducer_Lisp.bs.js");
var ReducerExternal_LispValue = require("../ReducerExternal/ReducerExternal_LispValue.bs.js");

var parse = Reducer_Lisp.parse;

var $$eval = Reducer_Lisp.$$eval;

function examplesShow(param) {
  console.log("Reducer.Lisp parse examples");
  console.log("case 1");
  console.log(Reducer_Lisp.showResult(Reducer_Lisp.parse("1")));
  console.log("case (1)");
  console.log(Reducer_Lisp.showResult(Reducer_Lisp.parse("(1)")));
  console.log("case 1+2");
  console.log(Reducer_Lisp.showResult(Reducer_Lisp.parse("1+2")));
  console.log("case add(1,2)");
  console.log(Reducer_Lisp.showResult(Reducer_Lisp.parse("add(1,2)")));
  console.log("case 1+2*3");
  console.log(Reducer_Lisp.showResult(Reducer_Lisp.parse("1+2*3")));
  
}

function examplesEval(param) {
  console.log("Reducer.Lisp.eval examples");
  console.log("case 1");
  console.log(ReducerExternal_LispValue.showResult(Reducer_Lisp.$$eval("1")));
  console.log("case 1+2");
  console.log(ReducerExternal_LispValue.showResult(Reducer_Lisp.$$eval("1+2")));
  console.log("case 1+(2+3)");
  console.log(ReducerExternal_LispValue.showResult(Reducer_Lisp.$$eval("1+(2+3)")));
  
}

function examples(param) {
  examplesShow(undefined);
  examplesEval(undefined);
  
}

var Examples = {
  examplesShow: examplesShow,
  examplesEval: examplesEval,
  examples: examples
};

var MathJsParse;

var Lisp;

var ListExt;

var LV;

exports.MathJsParse = MathJsParse;
exports.Lisp = Lisp;
exports.ListExt = ListExt;
exports.LV = LV;
exports.parse = parse;
exports.$$eval = $$eval;
exports.Examples = Examples;
/* Reducer_Lisp Not a pure module */
