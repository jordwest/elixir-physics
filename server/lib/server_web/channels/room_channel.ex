defmodule ServerWeb.RoomChannel do
    use Phoenix.Channel

    def join("room:lobby", _message, socket) do
        Physics.Server.step()
        body_id = Physics.Server.add_body(0.0, 200.0)
        socket = assign(socket, :body_id, body_id)
        {:ok, body_id, socket}
    end

    def join("room:" <> _private_room_id, _params, _socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def terminate(_msg, socket) do
        IO.puts "====Leaving===="
        body_id = socket.assigns[:body_id]
        Physics.Server.del_body(body_id)
        IO.puts ("Deleting body " <> body_id)
    end
end
