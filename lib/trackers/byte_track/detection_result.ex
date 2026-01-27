defmodule TrackForgex.Trackers.ByteTrack.DetectionResult do
  @moduledoc """
  ByteTrack detection result implementation.
  """

  @type t() :: %__MODULE__{
    bbox: TrackForgex.Utils.BBox.t(),
    score: float(),
    class_id: integer(),
    track_id: integer(),
    state: atom(),
    is_activated: boolean(),
    frame_id: integer(),
    start_frame: integer(),
    tracklet_len: integer()
  }

  defstruct [
    bbox: %TrackForgex.Utils.BBox{x: 0.0, y: 0.0, w: 0.0, h: 0.0},
    score: 0.0,
    class_id: 0,
    track_id: 0,
    state: :new,
    is_activated: false,
    frame_id: 0,
    start_frame: 0,
    tracklet_len: 0
  ]
end
