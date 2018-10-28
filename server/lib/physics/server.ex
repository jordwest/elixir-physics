defmodule Physics.Server do
    use GenServer

    def start_link do
        {:ok, pid} = GenServer.start_link(Physics.Server, 0, [name: Physics.Server])
    end

    @impl true
    def init(start_val) do
        IO.puts "Starting Physics NIF server"
        result = Physics.Native.state_new()
        Physics.Native.state_add_body(result, 0.0, 0.0)
        {:ok, result}
    end

    @impl true
    def handle_cast(:step, state) do
        Physics.Native.state_step(state)
        {:noreply, state}
    end

    @impl true
    def handle_call({:get_pos, body_id}, _from, state) do
      result = Physics.Native.state_get_pos(state, body_id)
      {:reply, result, state}
    end

    @impl true
    def handle_call({:add_body, x, y}, _from, state) do
      body_id = Physics.Native.state_add_body(state, x, y)
      {:reply, body_id, state}
    end

    def add_body(x, y), do: GenServer.call(__MODULE__, {:add_body, x, y})
    def get_pos(body_id), do: GenServer.call(__MODULE__, {:get_pos, body_id})
    def step(), do: GenServer.cast(__MODULE__, :step)
    def get_all() do
        {x, y, r} = get_pos(0)
        %{
            0 => %{:x => x, :y => y, :r => r}
        }
    end
end
