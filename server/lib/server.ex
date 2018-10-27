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
    {:ok, pid} = GenServer.start_link(Physics.Server, 0)
    body_id = Physics.Server.add_body(pid, 0.0, 0.0)
    body_id_2 = Physics.Server.add_body(pid, 0.0, 0.0)
    Physics.Server.step(pid)
    Physics.Server.step(pid)
    {x, y, r} = Physics.Server.get_pos(pid, body_id)
    IO.puts x
    IO.puts y
    IO.puts r
    Physics.Server.step(pid)
    IO.puts "----"
    {x, y, r} = Physics.Server.get_pos(pid, body_id)
    IO.puts x
    IO.puts y
    IO.puts r
    {:ok, pid}
  end
end
