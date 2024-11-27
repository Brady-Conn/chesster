defmodule Chesster.InitEngine do
  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(arg) do
    # check for stockfish otherwise build with make
    if File.exists?("#{arg}/stockfish") do
      :ok
    else
      System.cmd("make", ["-j", "build"], cd: arg)
    end
  end
end
