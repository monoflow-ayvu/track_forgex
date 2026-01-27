defmodule TrackForgex.Trackers.ByteTrack do
  @moduledoc """
  ByteTracker is a state-of-the-art multi-object tracking (MOT) system that achieves high performance
  by associating every detection box across video frames, including low-confidence ones.
  Instead of discarding uncertain detections, ByteTracker uses them to improve tracking accuracy,
  especially for occluded or partially visible objects.

  The system works in a tracking-by-detection paradigm: an object detector first identifies objects
  in each frame, producing bounding boxes with confidence scores. ByteTracker then applies a two-phase
  association process. In the first phase, high-confidence detections are associated with existing tracks
  using motion prediction (Kalman filter) and appearance similarity (ReID features).
  In the second phase, low-confidence detections are associated with unconfirmed or lost tracks to
  recover missed objects.

  This approach allows ByteTracker to maintain consistent tracks even during occlusions and achieves
  strong performance metrics, such as 80.3 MOTA and 77.3 IDF1 on the MOT17 benchmark while
  running at 30 FPS on a single GPU.
  """

  alias TrackForgex.Native
  alias TrackForgex.Trackers.ByteTrack.DetectionResult
  alias TrackForgex.Trackers.ByteTrack.Settings
  alias TrackForgex.Utils.Detection

  @doc """
  Create a new ByteTracker instance.

  ## Examples

  ```elixir
  iex> settings = %TrackForgex.Trackers.ByteTrack.Settings{track_thresh: 0.5, track_buffer: 30, match_thresh: 0.8, det_thresh: 0.6}
  iex> byte_track = TrackForgex.Trackers.ByteTrack.new(settings)
  iex> is_reference(byte_track) == true
  ```
  """
  @spec new(Settings.t()) :: reference()
  def new(%Settings{} = settings) do
    Native.create_byte_track(settings)
  end

  @doc """
  Update the ByteTracker instance with new detections.

  ## Examples

  ```elixir
  iex> settings = %TrackForgex.Trackers.ByteTrack.Settings{track_thresh: 0.5, track_buffer: 30, match_thresh: 0.8, det_thresh: 0.6}
  iex> byte_track = TrackForgex.Trackers.ByteTrack.new(settings)
  iex> detections = [%TrackForgex.Utils.Detection{bbox: %TrackForgex.Utils.BBox{x: 0.0, y: 1.0, w: 0.0, h: 0.0}, score: 0.9, class_id: 0}]
  iex> results = TrackForgex.Trackers.ByteTrack.update(byte_track, detections)
  iex> results # list of DetectionResult structs
  ```
  """
  @spec update(reference(), list(Detection.t())) :: list(DetectionResult.t())
  def update(instance, detections) when is_reference(instance) and is_list(detections) do
    Native.byte_track_update(instance, detections)
  end
end
