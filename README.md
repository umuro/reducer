# Reducer

Map MathJs parse tree to LISP and run LISP
All syntatic sugar can be mapped to LIST. Therefore MathJs becomes a complete functional programming language

## Installation

```sh
npm install
```

## Build

- Build: `npm run build`
- Clean: `npm run clean`
- Build & watch: `npm run start`

## Run

```sh
node src/Demo.bs.js
```

## Notes

LISP is the most basic functional language. It has no syntax sugar. It's evaluated by using map-reduce. However it's a complete language. Any syntax sugar in any language can be expressed in LISP.

Here I map MathJs parser to LISP. Thus MathJs scripts will become a complete functional language. The LISP map-reduce is in place. However, not all MathJs nodes are mapped yet. To do List:
- if then else
- arrays
- records
- function definition
- variable definition
- variable scope block

The remaining work is actually trivial. Maybe 3-4 hours of unit testing per node type.

In addition to being fully functional. The current implementation is polymorphic. The original MathJs parser is not polymorphic.

In list all language features are provided by functions. If we need a language feature then it is a function. Bingo. No pattern matching and special logic required.

An example of polymorphic function mapping is in ReducerExternal_LispLibrary.res

An external function is called if and only if it's full type signature is matching. Thus polymorphic functions can be defined. Like
- "hello " + "word"
- 1 + 2

The search priority of functions will be in this order
1. User space. Defined in the script
2. Built-in extention. Look up for a mapping in ReducerExternal_LispLibrary.res
3. MathJs built-in

The whole map-reduce uses the Result monad. All run-time exceptions are converted to a Result monad. Because of this there is no need to look for patterns like n/0. Division by zero and all other exceptions enters the flow as a monad. If desired built-in functions can return a result monad also.

## Examples
module Reducer.Examples contains examples of parsing and evaluating. To execute run Demo.res

## Inheritance and Function Signatures
Rescript provides Inheritance
module Base = {
  let aMethod = () => { specialMethod -> commonMethod }
  let commonMethod = ...
  let specialMethod = ...
}

module Special = {
  use Base // This is inheritance
  let specialMethod = ...  // One can call Special.commonMethod and see the difference
}

If your library has common algorithms then you can use module inheritance.

Polymorphic function mapping will make the correct calls. This might be a cleaner implementation instead of overloading function definitions with switch calls.

However this is optional. You can still opt for internal switch statements.

To inherit or not? Are the switch statements all over the library? Then its time to refactor into inheriting modules

## TODO
- Calling MathJs library for default implementations
- if then else
- arrays
- records
- variable scope block
- function definition
- variable definition
