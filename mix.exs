defmodule TrackForgex.MixProject do
  use Mix.Project

  def project do
    [
      app: :track_forgex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.37.1", runtime: false}
    ]
  end
end
