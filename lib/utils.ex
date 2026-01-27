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

  @type t() :: %__MODULE__{
    x: float(),
    y: float(),
    w: float(),
    h: float()
  }

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


defmodule TrackForgex.Utils.Detection do
  @moduledoc """
  Detection implementation.
  """

  if Code.ensure_loaded?(Jason) do
    @derive Jason.Encoder
  end

  if Code.ensure_loaded?(JSON) do
    @derive JSON.Encoder
  end

  @type t() :: %__MODULE__{
    bbox: TrackForgex.Utils.BBox.t(),
    score: float(),
    class_id: integer()
  }

  defstruct [
    bbox: %TrackForgex.Utils.BBox{x: 0.0, y: 0.0, w: 0.0, h: 0.0},
    score: 0.0,
    class_id: 0
  ]
end

defimpl String.Chars, for: TrackForgex.Utils.Detection do
  def to_string(value) do
    "Detection(bbox: #{value.bbox}, score: #{value.score}, class_id: #{value.class_id})"
  end
end
