# Chesster
    An Elixir wrapper for the stockfish chess engine.
      - Stockfish source code: [github](https://github.com/official-stockfish/Stockfish)

# TODO
  - think about concurrency management
    - additional genserver layer to handle concurrency
    - one engine per game
    - think about reusing an engine after its game is over
  - figure out what to do with stockfish src files
    - basic makefile task created
    - update makefile task to be more dynamic, i.e. take cpu type arg
    - src files aren't that large so they can go to github, just need to figure out how to ignore the compiled files
    - look into having the app download the src files, that would solve the gitignore issue and provide latest version of engine
  - figure out hex publishing
  - add explicit shutdown to the stockfish process
  - expose elo settings for stockfish

