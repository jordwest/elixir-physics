defmodule Physics.Server do
    use GenServer

    @impl true
    def init(start_val) do
        IO.puts "Starting Physics NIF server with"
        IO.puts start_val
        {:ok, start_val}
    end

    @impl true
    def handle_cast({:add, val}, state) do
        case Physics.Native.add(state, val) do
            {:ok, new_state} -> {:noreply, new_state}
            _ -> {:noreply, state}
        end
    end

    @impl true
    def handle_call(:ask, _from, state) do
      {:reply, state, state}
    end
end
