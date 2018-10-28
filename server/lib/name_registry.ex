defmodule NameRegistry do
    use GenServer

    def start_link do
        {:ok, pid} = GenServer.start_link(NameRegistry, 0, [name: NameRegistry])
    end

    @impl true
    def init(start_val) do
        IO.puts "Starting name registry"
        {:ok, %{}}
    end

    @impl true
    def handle_cast({:set_name, body_id, name}, state) do
        {:noreply, Map.put(state, body_id, name)}
    end

    @impl true
    def handle_call(:get_names, _from, state) do
      {:reply, state, state}
    end

    def set_name(body_id, name), do: GenServer.cast(__MODULE__, {:set_name, body_id, name})
    def get_names(), do: GenServer.call(__MODULE__, :get_names)
end
