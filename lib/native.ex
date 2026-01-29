defmodule TrackForgex.Native do
  @moduledoc """
  Native interface to the TrackForgex library.

  Do not use this module directly, use the `TrackForgex.Trackers.ByteTrack` module instead.
  """
  @version Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :track_forgex,
    crate: "track_forgex",
    base_url: "https://github.com/monoflow-ayvu/track_forgex/releases/download/v#{@version}",
    force_build: System.get_env("TRACK_FORGE_FORCE_BUILD") in ["1", "true"],
    version: @version,
    nif_versions: ~w(2.15 2.16 2.17),
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      aarch64-unknown-linux-musl
      arm-unknown-linux-gnueabihf
      riscv64gc-unknown-linux-gnu
      riscv64gc-unknown-linux-musl
      x86_64-apple-darwin
      x86_64-pc-windows-gnu
      x86_64-pc-windows-msvc
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
    )

  @doc """
  Create a new byte track instance.
  """
  def create_byte_track(%TrackForgex.Trackers.ByteTrack.Settings{} = _settings),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Update the byte track instance with new detections.
  """
  def byte_track_update(_instance, _detections), do: :erlang.nif_error(:nif_not_loaded)
end
