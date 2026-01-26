defmodule TrackForgex.Trackers.ByteTrack do
  @moduledoc """
  ByteTrack tracker implementation.
  """

  defstruct [
      track_thresh: 0.5,
      track_buffer: 30,
      match_thresh: 0.8,
      det_thresh: 0.6
    ]
end
