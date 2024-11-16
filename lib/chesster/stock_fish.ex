defmodule Chesster.StockFish do
  use GenServer
  def start_link(dir) do
    GenServer.start_link(__MODULE__, dir, name: __MODULE__)
  end

  def init(dir) do
    state = %{ dir: dir, port: nil }
    {:ok, state, {:continue, :start_stockfish}}
  end

  def handle_continue(:start_stockfish, state) do
    port = Port.open({:spawn_executable, state.dir}, [:binary, :exit_status, :stderr_to_stdout, :stream])
    state = Map.put(state, :port, port)
    {:noreply, state}
  end

  def handle_info({_port, {:data, data}}, state) do
    IO.puts data
    {:noreply, state}
  end
end
