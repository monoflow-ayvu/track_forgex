defmodule TrackForgexTest do
  use ExUnit.Case

  alias TrackForgex.Trackers.ByteTrack
  alias TrackForgex.Native

  doctest TrackForgex

  test "greets the world" do
    assert Native.create_byte_track(%ByteTrack{track_thresh: 0.5, track_buffer: 30, match_thresh: 0.8, det_thresh: 0.6}) == :world
  end
end
