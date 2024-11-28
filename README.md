# Chesster
    An Elixir wrapper for the stockfish chess engine.
      - Stockfish source code: [github](https://github.com/official-stockfish/Stockfish)

# Usage

  This is still in early development.

  To run locally

  - download the latest stokfish release from the github liked above.
  - copy the src folder from the stockfish release to Chesster/priv/stockfish/src
  - the makefile task should build the engine but if you want to build it manually, run `make -j build ARCH=<cpu_type>` from the src folder
  - run `mix phx.server`, this will start the engine, mainly used for testing and confirming the engine compiled correctly
  - intended use is to be included as a dependency in a parent application, functionality is not gaurenteed to be stable currently
    - include Chesster in the children list of the parent application
    - include a `:chesster` key in the config for the parent application with an `:on_move` function that will be called when a move is made by the engine, it will take a single string argument which is the move made by the engine
    - include a `:cpu` key in the `:chesster` config with a string value of the cpu type, i.e. `"apple-silicon"` or `"x86-64"`
    - the function Chesster.StockFish.send_move/1 can be used to send a users move to the engine, also takes a single string argument, must be in the format of a [fenstring](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)

# TODO
  - think about concurrency management
    - additional genserver layer to handle concurrency
    - one engine per game
    - think about reusing an engine after its game is over
  - figure out what to do with stockfish src files
    - basic makefile task created
    - src files aren't that large so they can go to github, just need to figure out how to ignore the compiled files
    - look into having the app download the src files, that would solve the gitignore issue and provide latest version of engine
  - figure out hex publishing

