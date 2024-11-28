defmodule Chesster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Chesster.StockFish,  "_build/dev/lib/chesster/priv/stockfish/src/stockfish"}, #only for testing, concurrency layer will handle this
    ]
    config = Application.get_env(:chesster, :config) || %{ :sf_src => "_build/dev/lib/chesster/priv/stockfish/src"}
    compile_engine = Task.async(fn -> Chesster.InitEngine.run(config.sf_src) end)
    Task.await(compile_engine, 500000) # check for compiled stockfish engine, await the build if not compiled
    Task.shutdown(compile_engine)
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chesster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
