defmodule Physics.Native do
    use Rustler, otp_app: :server, crate: :physics

    # When the NIF is loaded, it will override these functions

    def state_new(), do: :erlang.nif_error(:nif_not_loaded)
    def state_step(_state), do: :erlang.nif_error(:nif_not_loaded)
    def state_apply_force(_state, _body_id, _fx, _fy, _ft), do: :erlang.nif_error(:nif_not_loaded)
    def state_get_body_ids(_state), do: :erlang.nif_error(:nif_not_loaded)
    def state_add_body(_state, _x, _y), do: :erlang.nif_error(:nif_not_loaded)
    def state_del_body(_state, _id), do: :erlang.nif_error(:nif_not_loaded)
end
