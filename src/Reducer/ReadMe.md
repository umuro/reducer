To interface your library there only 2 files to be modified:
- Reducer/Reducer_Extension/Reducer_Extension_CodeTreeValue.res

  This is where your additional types are referred for the dispatcher.

- Reducer/Reducer_Extension/Reducer_ReducerLibrary.res

  This is where dispatching to your library is done. If the dispatcher becomes beastly then feel free to divide it into submodules.

The Reducer is built to use different external libraries as well as different external parsers. Both external parsers and external libraries are plugins.
