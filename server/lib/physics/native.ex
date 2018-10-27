defmodule Physics.Native do
    use Rustler, otp_app: :server, crate: :physics

    # When the NIF is loaded, it will override these functions

    def state_new(), do: :erlang.nif_error(:nif_not_loaded)
    def state_step(_state), do: :erlang.nif_error(:nif_not_loaded)
    def state_get_pos(_state, _body_id), do: :erlang.nif_error(:nif_not_loaded)
    def state_add_body(_state, _x, _y), do: :erlang.nif_error(:nif_not_loaded)
end
