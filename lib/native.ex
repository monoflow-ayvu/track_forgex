defmodule TrackForgex.Native do
  use Rustler, otp_app: :track_forgex, crate: "TrackForgex"

  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
