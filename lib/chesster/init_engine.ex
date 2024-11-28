defmodule Chesster.InitEngine do
  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(arg) do
    # check for stockfish otherwise build with make
    if File.exists?("#{arg}/stockfish") do
      IO.puts("stockfish already built")
      :ok
    else
      IO.puts("building stockfish")
      cpu = System.get_env("CPU") || "apple-silicon"
      System.cmd("make", ["-j", "build", "ARCH=#{cpu}"], cd: arg)
    end
  end
end
