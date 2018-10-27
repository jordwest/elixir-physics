defmodule Server do
  use Application

  @moduledoc """
  Documentation for Server.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Server.hello()
      :world

  """
  def start(_type, _args) do
    IO.puts "Hello World"
    case Elixir.Physics.Native.add(2,2) do
      {:ok, n} -> IO.puts n
      _ -> IO.puts "Error"
    end
    IO.puts "Done"
    {:ok, pid} = GenServer.start_link(Physics.Server, 0)
    GenServer.cast(pid, {:add, 5})
    GenServer.cast(pid, {:add, 2})
    GenServer.cast(pid, {:add, 3})
    IO.puts GenServer.call(pid, :ask)
    {:ok, pid}
  end
end
