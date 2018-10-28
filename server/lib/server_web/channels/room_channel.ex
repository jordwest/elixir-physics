defmodule ServerWeb.RoomChannel do
    use Phoenix.Channel

    def join("room:lobby", _message, socket) do
        Physics.Server.step()
        body_id = Physics.Server.add_body(Enum.random(-500..500) / 1, Enum.random(200..450) / 1)
        socket = assign(socket, :body_id, body_id)
        {:ok, body_id, socket}
    end

    def join("room:" <> _private_room_id, _params, _socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in("move", %{"action" => action}, socket) do
        body_id = socket.assigns[:body_id]
        IO.puts "Applying force to "
        IO.puts body_id
        case action do
            "thrust" -> Physics.Server.apply_force(body_id, 0.0, 10.0, 0.0)
            "cw" -> Physics.Server.apply_force(body_id, 3.0, 0.0, -1.2)
            "ccw" -> Physics.Server.apply_force(body_id, -3.0, 0.0, 1.2)
        end
        {:noreply, socket}
    end

    def terminate(_msg, socket) do
        IO.puts "====Leaving===="
        body_id = socket.assigns[:body_id]
        Physics.Server.del_body(body_id)
    end
end
