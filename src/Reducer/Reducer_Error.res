type reducerError =
| RerrFunctionExpected( string )
| RerrJs(option<string>, option<string>)   // Javascript Exception
| RerrTodo(string) // To do
| RerrUnexecutedCode( string )

let showError = (err) => switch err {
  | RerrTodo( msg ) => `TODO: ${msg}`
  | RerrJs( omsg, oname ) => {
      let answer = "JS Exception:"
      let answer = switch oname {
        | Some(name) => `${answer} ${name}`
        | _ => answer
      }
      let answer = switch omsg {
        | Some(msg) => `${answer}: ${msg}`
        | _ => answer
      }
      answer
  }
  | RerrUnexecutedCode( codeString ) => `Unexecuted code remaining: ${codeString}`
  | RerrFunctionExpected( msg ) => `Function expected: ${msg}`
  }
