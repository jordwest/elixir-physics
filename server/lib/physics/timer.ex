defmodule Physics.Timer do
    use GenServer

    def start_link do
        {:ok, pid} = GenServer.start_link(__MODULE__, 0)
    end

    @impl true
    def init(start_val) do
        IO.puts "Starting Timer"
        Process.send_after(self, :tick, 1_000)
        {:ok, nil}
    end

    @impl true
    def handle_info(:tick, state) do
        Physics.Server.step()
        data = Physics.Server.get_all()
        ServerWeb.Endpoint.broadcast("room:lobby", "update", data)
        Process.send_after(self, :tick, 32)
        {:noreply, state}
    end
end
