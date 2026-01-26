defmodule TrackForgex.Native do
  use Rustler, otp_app: :track_forgex, crate: :track_forgex

  @doc """
  Create a new byte track instance.
  """
  def create_byte_track(%TrackForgex.Trackers.ByteTrackSettings{} = _settings), do: :erlang.nif_error(:nif_not_loaded)
end
