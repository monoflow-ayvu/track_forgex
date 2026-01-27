defmodule TrackForgex.Trackers.ByteTrackSettings do
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

defmodule TrackForgex.Trackers.ByteTrackDetectionResult do
  @moduledoc """
  ByteTrack detection result implementation.
  """

  defstruct [
    bbox: %TrackForgex.Utils.BBox{x: 0, y: 0, w: 0, h: 0},
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
