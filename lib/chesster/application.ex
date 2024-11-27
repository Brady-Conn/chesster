defmodule Chesster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Chesster.InitEngine,  "_build/dev/lib/chesster/priv/stockfish/src"},
      {Chesster.StockFish,  "_build/dev/lib/chesster/priv/stockfish/src/stockfish"}, #only for testing, parent process will handle this
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chesster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
