defmodule TrackForgex.Native do
  use Rustler, otp_app: :track_forgex, crate: :track_forgex

  @doc """
  Create a new byte track instance.
  """
  def create_byte_track(%TrackForgex.Trackers.ByteTrack.Settings{} = _settings), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Update the byte track instance with new detections.
  """
  def byte_track_update(_instance, _detections), do: :erlang.nif_error(:nif_not_loaded)
end
