defmodule NativeTest do
  use ExUnit.Case

  alias TrackForgex.Trackers.ByteTrack
  alias TrackForgex.Native

  doctest Native

  test "create_byte_track" do
    byte_track =
      Native.create_byte_track(%ByteTrack.Settings{
        track_thresh: 0.5,
        track_buffer: 30,
        match_thresh: 0.8,
        det_thresh: 0.6
      })

    assert byte_track != nil
    assert is_reference(byte_track)
  end

  test "byte_track_update" do
    byte_track =
      Native.create_byte_track(%ByteTrack.Settings{
        track_thresh: 0.5,
        track_buffer: 30,
        match_thresh: 0.8,
        det_thresh: 0.6
      })

    assert byte_track != nil
    assert is_reference(byte_track)

    results =
      Native.byte_track_update(byte_track, [
        %TrackForgex.Utils.Detection{
          bbox: %TrackForgex.Utils.BBox{x: 0.0, y: 1.0, w: 0.0, h: 0.0},
          score: 0.5,
          class_id: 1
        },
        %TrackForgex.Utils.Detection{
          bbox: %TrackForgex.Utils.BBox{x: 0.0, y: 1.0, w: 0.0, h: 0.0},
          score: 0.9,
          class_id: 0
        }
      ])

    assert results == [
             %TrackForgex.Trackers.ByteTrack.DetectionResult{
               bbox: %TrackForgex.Utils.BBox{h: 0.0, w: 0.0, x: 0.0, y: 1.0},
               class_id: 0,
               frame_id: 1,
               is_activated: true,
               score: 0.8999999761581421,
               start_frame: 1,
               state: :tracked,
               track_id: 1,
               tracklet_len: 0
             }
           ]
  end
end
