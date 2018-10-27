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
    case Elixir.Physics.add(2,2) do
      {:ok, n} -> IO.puts n
      _ -> IO.puts "Error"
    end
    IO.puts "Done"
  end
end
