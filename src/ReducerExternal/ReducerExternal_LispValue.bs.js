// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';


function show(aValue) {
  if (typeof aValue === "number") {
    return "Undefined";
  }
  switch (aValue.TAG | 0) {
    case /* LvBool */0 :
    case /* LvNumber */1 :
        return String(aValue._0);
    case /* LvString */2 :
        return "\"" + aValue._0 + "\"";
    
  }
}

function showResult(x) {
  if (x.TAG === /* Ok */0) {
    return "Ok(" + show(x._0) + ")";
  } else {
    return "Error(" + String(x._0) + ")";
  }
}

exports.show = show;
exports.showResult = showResult;
/* No side effect */
