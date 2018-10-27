defmodule ServerWeb.RoomChannel do
    use Phoenix.Channel

    def join("room:lobby", _message, socket) do
        Physics.Server.step()
        data = Physics.Server.get_all()
        {:ok, data, socket}
    end

    def join("room:" <> _private_room_id, _params, _socket) do
        {:error, %{reason: "unauthorized"}}
    end
end