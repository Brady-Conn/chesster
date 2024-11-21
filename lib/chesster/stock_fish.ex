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
    Port.close(state.port)
    {:stop, :normal, state}
  end

  def handle_info({_port, {:data, "id name Stockfish 17\nid author the Stockfish developers (see AUTHORS file)\n\noption name Debug Log File type string default <empty>\noption name NumaPolicy type string default auto\noption name Threads type spin default 1 min 1 max 1024\noption name Hash type spin default 16 min 1 max 33554432\noption name Clear Hash type button\noption name Ponder type check default false\noption name MultiPV type spin default 1 min 1 max 256\noption name Skill Level type spin default 20 min 0 max 20\noption name Move Overhead type spin default 10 min 0 max 5000\noption name nodestime type spin default 0 min 0 max 10000\noption name UCI_Chess960 type check default false\noption name UCI_LimitStrength type check default false\noption name UCI_Elo type spin default 1320 min 1320 max 3190\noption name UCI_ShowWDL type check default false\noption name SyzygyPath type string default <empty>\noption name SyzygyProbeDepth type spin default 1 min 1 max 100\noption name Syzygy50MoveRule type check default true\noption name SyzygyProbeLimit type spin default 7 min 0 max 7\noption name EvalFile type string default nn-1111cefa1111.nnue\noption name EvalFileSmall type string default nn-37f18f62d772.nnue\nuciok\n"}}, state) do
    IO.inspect("uciok")
    Port.command(state.port, "ucinewgame\n")
    {:noreply, state, {:continue, :is_ready}}
  end

  def handle_info({_port, {:data, "Stockfish 17 by the Stockfish developers (see AUTHORS file)\n"}}, state) do
    IO.inspect("stockfish 17")
    if !state.uci_init do
      Port.command(state.port, "uci\n")
      state = Map.put(state, :uci_init, true)
      {:noreply, state}
    end
    {:noreply, state}
  end

  def handle_info({_port, {:data, "readyok\n"}}, state) do
    IO.inspect("readyok")
    {:noreply, state}
  end

  def handle_info({_port, {:data, data}}, state) do
    IO.inspect(data)
    regex = ~r/bestmove .+/
    is_best_move = Regex.match?(regex, data)
    if is_best_move do
      config = Application.get_env(:chesster, :config) || %{on_move: fn _d -> nil end}
      config.on_move(data)
    end
    {:noreply, state}
  end
end
