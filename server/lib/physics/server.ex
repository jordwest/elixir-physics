defmodule Physics.Server do
    use GenServer

    @impl true
    def init(start_val) do
        IO.puts "Starting Physics NIF server with"
        IO.puts start_val
        result = Physics.Native.state_new()
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

    def add_body(pid, x, y), do: GenServer.call(pid, {:add_body, x, y})
    def get_pos(pid, body_id), do: GenServer.call(pid, {:get_pos, body_id})
    def step(pid), do: GenServer.cast(pid, :step)
end
