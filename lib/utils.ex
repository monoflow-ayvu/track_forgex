defmodule TrackForgex.Utils.BBox do
  @moduledoc """
  BBox implementation.
  """

  if Code.ensure_loaded?(Jason) do
    @derive Jason.Encoder
  end

  if Code.ensure_loaded?(JSON) do
    @derive JSON.Encoder
  end

  defstruct [
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0
  ]
end

defimpl String.Chars, for: TrackForgex.Utils.BBox do
  def to_string(value) do
    "BBox(x: #{value.x}, y: #{value.y}, w: #{value.w}, h: #{value.h})"
  end
end
