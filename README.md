# Reducer

Map MathJs parse tree to LISP-like code tree and reduce (run) the code tree to an answer
Reducer is LISP inspired. All syntactic sugar can be mapped to LISP. Therefore MathJs becomes a complete functional programming language. We reduce LISP expressions

## Installation

```sh
yarn install
```

## Build

- Build: `yarn build`
- Clean: `yarn clean`

## Run

```sh
yarn run main
```

## Test

```sh
yarn test
yarn coverage
```

## Usage

```res
Reducer.eval("<code>")
```

Evaluating code returns a value of type:

```res
ReducerInterface.ExpressionValue.expressionValue
```

External functions to the reducer are introduced in:

```res
ReducerInterface.ExternalLibrary
```

The types in code tree value are what we need to call the external functions.
ExternalLibrary and ExpressionValue are configurations of Reducer.
Reducer itself does not depend on external libraries.

## Extending the Library of Functions

The module ReducerInterface contains the definitions to extend it with functions.

- ReducerInterface.ExpressionValue is to define new data types necessary for the functions
- ReducerInterface.ExternalLibrary is to add new functions to the language
  All MathJs functions are available by default

## Notes

LISP is the most basic functional language. In fact, LISP can be the assembly code of all functional languages. It has no syntax sugar. It's evaluated by using map-reduce. However it's a complete language. Any syntax sugar in any language can be expressed in LISP. Actually, LISP is just a code tree. There is nothing else. Code Tree here is map-reduced similar to LISP but it is aggressive to resolve the external calls as soon as possible. Lazy evaluation will be enabled depending on context

Here I map MathJs parser to code tree. Thus MathJs scripts will become a complete functional language. The code tree map-reduce is in place. However, not all MathJs nodes are mapped yet. To do List:

- if then else
- arrays
- records
- function definition
- variable definition
- variable scope block

In addition to being fully functional. The current implementation is polymorphic. The original MathJs parser is not polymorphic. This protects one from writing dispatch modules and type handling while providing external libraries.

Like LISP, all language features are provided by functions. If we need a language feature then it is a function. Bingo. No modification to the code tree is required.

An example of polymorphic function mapping is in ReducerInterface.ExternalLibrary.res

An external function is called if and only if it's full type signature is matching. Thus polymorphic functions can be defined. Like

- "hello " + "word"
- 1 + 2

The search priority of functions will be in this order
1\. User space. Defined in the script
2\. Built-in extension. Special domains to extend the Reducer. Look up for a mapping in ReducerInterface.ExternalLibrary.res
3\. Very Basic built-ins not provided by MathJs library. If they are very basic to computer languages in general.
4\. MathJs built-in

The whole tree code map-reduce uses the Result monad. All run-time exceptions are converted to a Result monad. Because of this there is no need to look for patterns like n/0. Division by zero and all other exceptions enters the flow as a monad. If desired built-in functions can return a result monad also.

## Examples

See Reducer_test.res

## Inheritance and Function Signatures

Rescript provides Inheritance

```res
module Base = {
  let aMethod = () => { specialMethod -> commonMethod }
  let commonMethod = ...
  let specialMethod = ...
}

module Special = {
  use Base // This is inheritance
  let specialMethod = ...  // One can call Special.commonMethod and see the difference
}
```

If your library has common algorithms then you can use module inheritance.

Polymorphic function mapping will make the correct calls. This might be a cleaner implementation instead of overloading function definitions with switch calls.

However this is optional. You can still opt for internal switch statements.

To inherit or not? Are the switch statements all over the library? Then its time to refactor into inheriting modules

## TODO

- Do the first integration at Least one function
- variable definition // bindings // execution context

==============

- if then else
- arrays
- records
- variable scope block
- function definition
