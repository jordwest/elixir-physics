defmodule Physics.Server do
    use GenServer

    def start_link do
        {:ok, pid} = GenServer.start_link(Physics.Server, 0, [name: Physics.Server])
    end

    @impl true
    def init(start_val) do
        IO.puts "Starting Physics NIF server"
        result = Physics.Native.state_new()
        # Physics.Native.state_add_body(result, 0.0, 80.0)
        {:ok, result}
    end

    @impl true
    def handle_cast(:step, state) do
        Physics.Native.state_step(state)
        {:noreply, state}
    end

    @impl true
    def handle_cast({:del_body, body_id}, state) do
      Physics.Native.state_del_body(state, body_id)
      {:noreply, state}
    end

    @impl true
    def handle_cast({:apply_force, body_id, fx, fy, ft}, state) do
      Physics.Native.state_apply_force(state, body_id, fx, fy, ft)
      {:noreply, state}
    end

    @impl true
    def handle_call(:get_body_ids, _from, state) do
      result = Physics.Native.state_get_body_ids(state)
      {:reply, result, state}
    end

    @impl true
    def handle_call({:add_body, x, y}, _from, state) do
      body_id = Physics.Native.state_add_body(state, x, y)
      {:reply, body_id, state}
    end

    def add_body(x, y), do: GenServer.call(__MODULE__, {:add_body, x, y})
    def del_body(body_id), do: GenServer.cast(__MODULE__, {:del_body, body_id})
    def apply_force(body_id, fx, fy, ft), do: GenServer.cast(__MODULE__, {:apply_force, body_id, fx, fy, ft})
    def get_body_ids(), do: GenServer.call(__MODULE__, :get_body_ids)
    def step(), do: GenServer.cast(__MODULE__, :step)
    def get_all() do
        bodies = Enum.map(get_body_ids(), fn {id, x, y, r} -> %{:id => id, :x => x, :y => y, :r => r} end)
        %{
            :bodies => bodies
        }
    end
end
