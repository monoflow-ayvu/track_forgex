defmodule TrackForgex.Trackers.ByteTrackTest do
  use ExUnit.Case

  doctest TrackForgex.Trackers.ByteTrack

  describe "usage tests" do
    test "basic usage" do
      # Initialize settings for ByteTrack
      settings = %TrackForgex.Trackers.ByteTrack.Settings{
        track_thresh: 0.5,
        track_buffer: 30,
        match_thresh: 0.8,
        det_thresh: 0.6
      }

      # Create a new ByteTrack instance
      byte_track = TrackForgex.Trackers.ByteTrack.new(settings)

      # Simulated detection input for Frame 1: [x, y, w, h], score, class_id
      frame_1_detections = [
        %TrackForgex.Utils.Detection{
          bbox: %TrackForgex.Utils.BBox{x: 100.0, y: 100.0, w: 50.0, h: 100.0},
          score: 0.9,
          class_id: 0
        },
        %TrackForgex.Utils.Detection{
          bbox: %TrackForgex.Utils.BBox{x: 200.0, y: 200.0, w: 60.0, h: 120.0},
          score: 0.85,
          class_id: 0
        }
      ]

      # Update tracker with first frame
      tracks_1 = TrackForgex.Trackers.ByteTrack.update(byte_track, frame_1_detections)

      # Assert expected number of tracks
      assert length(tracks_1) == 2

      # Simulated detection input for Frame 2 with slight movement
      frame_2_detections = [
        %TrackForgex.Utils.Detection{
          bbox: %TrackForgex.Utils.BBox{x: 105.0, y: 102.0, w: 50.0, h: 100.0},
          score: 0.92,
          class_id: 0
        },
        %TrackForgex.Utils.Detection{
          bbox: %TrackForgex.Utils.BBox{x: 202.0, y: 201.0, w: 60.0, h: 120.0},
          score: 0.88,
          class_id: 0
        }
      ]

      # Update tracker with second frame
      tracks_2 = TrackForgex.Trackers.ByteTrack.update(byte_track, frame_2_detections)

      # Assert expected number of tracks in second frame
      assert length(tracks_2) == 2

      [first, last] = tracks_2

      assert first.track_id != last.track_id

      assert first.bbox != last.bbox
      assert first.score != last.score
      assert first.class_id == 0
      assert last.class_id == 0
      assert first.state == :tracked
      assert last.state == :tracked
    end
  end
end
