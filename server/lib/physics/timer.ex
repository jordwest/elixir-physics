defmodule Physics.Timer do
    use GenServer

    def start_link do
        {:ok, pid} = GenServer.start_link(__MODULE__, 0)
    end

    @impl true
    def init(_start_val) do
        IO.puts "Starting Timer"
        Process.send_after(self, :tick, 1_000)
        {:ok, {0, 0.0}}
    end

    @impl true
    def handle_info(:tick, {state, time}) do
        Physics.Server.step()
        data = Physics.Server.get_all()
        {room, new_state} = case state do
            0 -> {"room:lobby", 1}
            1 -> {"room:lobby2", 2}
            2 -> {"room:lobby3", 0}
        end
        ServerWeb.Endpoint.broadcast(room, "update", Map.put(data, "time", time))
        Process.send_after(self, :tick, 32)
        {:noreply, {new_state, time + 0.016}}
    end
end
