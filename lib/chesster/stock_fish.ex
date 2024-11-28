defmodule Chesster.StockFish do
  use GenServer
  def start_link(dir) do
    GenServer.start_link(__MODULE__, dir, name: __MODULE__)
  end

  def init(dir) do
    state = %{ dir: dir, port: nil, uci_init: false }
    {:ok, state, {:continue, :start_stockfish}}
  end

  def send_move(new_position) do
    GenServer.cast(__MODULE__, {:send_move, new_position})
  end

  def set_elo(elo) do
    GenServer.cast(__MODULE__, {:set_elo, elo})
  end

  def shutdown() do
    GenServer.call(__MODULE__, :shutdown)
  end

  def handle_continue(:start_stockfish, state) do
    port = Port.open({:spawn_executable, state.dir}, [:binary])
    state = Map.put(state, :port, port)
    {:noreply, state}
  end

  def handle_continue(:is_ready, state) do
    Port.command(state.port, "isready\n")
    {:noreply, state}
  end

  def handle_continue(:go, state) do
    Port.command(state.port, "go\n")
    {:noreply, state}
  end

  def handle_cast({:send_move, new_position}, state) do
    Port.command(state.port, "position fen #{new_position}\n")
    {:noreply, state, {:continue, :go}}
  end

  def handle_call(:shutdown, _from, state) do
    Port.command(state.port, "quit\n")
    Port.close(state.port)
    {:stop, :normal, state}
  end

  def handle_call(:set_elo, _from, state) do
    Port.command(state.port, "setoption name UCI_Elo value #{state.elo}\n")
    {:reply, :ok, state}

  end

  def handle_info({_port, {:data, data}}, state) do
    best_move_regex = ~r/^bestmove/
    initialize_regex = ~r/^Stockfish \d\d by the Stockfish developers/
    uci_regex = ~r/^id name Stockfish \d\d/
    ready_regex = ~r/^readyok/
    cond do
      data =~ best_move_regex ->
        config = Application.get_env(:chesster, :config) || %{:on_move => fn _d -> nil end}
        config.on_move(data)
        {:noreply, state}
      data =~ initialize_regex ->
        IO.inspect(data)
        Port.command(state.port, "uci\n")
        state = Map.put(state, :uci_init, true)
        {:noreply, state}
      data =~ uci_regex ->
        IO.inspect("uciok, setting UCI_LimitStrength to true and starting a new game")
        Port.command(state.port, "setoption name UCI_LimitStrength value true\n")
        Port.command(state.port, "ucinewgame\n")
        {:noreply, state, {:continue, :is_ready}}
      data =~ ready_regex ->
        IO.inspect("readyok")
        {:noreply, state}
      true ->
        IO.inspect(data)
        {:noreply, state}
    end
  end
end
