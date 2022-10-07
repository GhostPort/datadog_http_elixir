defmodule DatadogHttp.MixProject do
  use Mix.Project

  @version "0.0.2"

  def project do
    [
      app: :datadog_http,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test, "coveralls.github": :test],
      name: "Datadog HTTP",
      source_url: "https://github.com/GhostPort/datadog_http_elixir"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      env: env()
    ]
  end

  defp env do
    [
      base_url: "https://api.datadoghq.com"
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.18"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:bypass, "~> 2.1", only: :test},
      {:excoveralls, "~> 0.15", only: :test}
    ]
  end

  defp description do
    "A client for Datadog's HTTP API, useful for building integrations."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/GhostPort/datadog_http_elixir",
        "Datadog API Reference" => "https://docs.datadoghq.com/api/latest/"
      },
      maintainers: ["Christian Alexander"]
    ]
  end
end
