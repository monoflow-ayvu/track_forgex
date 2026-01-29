defmodule TrackForgex.MixProject do
  use Mix.Project

  @version File.read!("VERSION") |> String.trim()

  def project do
    [
      app: :track_forgex,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: "A port of trackforge from Rust to Elixir using Rustler.",
      docs: [extras: ["README.md", "CHANGELOG.md"], source_ref: "v#{@version}"],
      source_url: "https://github.com/monoflow-ayvu/track_forgex",
      package: [
        files: [
          "lib",
          "mix.exs",
          "README.md",
          "CHANGELOG.md",
          "LICENSE",
          "VERSION",
          "native",
          "checksum-*.exs"
        ],
        maintainers: ["Fernando Mumbach"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/monoflow-ayvu/track_forgex"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler_precompiled, "~> 0.8"},
      {:rustler, "~> 0.37.1", optional: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "credo suggest --strict --all"
      ]
    ]
  end
end
