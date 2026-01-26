defmodule TrackForgex.Native do
  use Rustler, otp_app: :track_forgex, crate: "TrackForgex"

  @doc """
  Create a new byte track instance.
  """
  def create_byte_track(%TrackForgex.Trackers.ByteTrack{} = _settings), do: :erlang.nif_error(:nif_not_loaded)
end
