defmodule TrackForgexTest do
  use ExUnit.Case

  alias TrackForgex.Trackers.ByteTrackSettings
  alias TrackForgex.Native

  doctest TrackForgex

  test "create_byte_track" do
    byte_track = Native.create_byte_track(%ByteTrackSettings{track_thresh: 0.5, track_buffer: 30, match_thresh: 0.8, det_thresh: 0.6})
    assert byte_track != nil
    assert is_reference(byte_track)
  end
end
