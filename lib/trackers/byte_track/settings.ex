defmodule TrackForgex.Trackers.ByteTrack.Settings do
  @moduledoc """
  ByteTrack tracker implementation.
  """

  @type t :: %__MODULE__{
          track_thresh: float(),
          track_buffer: integer(),
          match_thresh: float(),
          det_thresh: float()
        }

  defstruct track_thresh: 0.5,
            track_buffer: 30,
            match_thresh: 0.8,
            det_thresh: 0.6
end
