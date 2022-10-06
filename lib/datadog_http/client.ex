defmodule DatadogHttp.Client do
  @moduledoc """
  Functions to build a Tesla client for handling HTTP requests.
  """

  @doc """
  Creates a new Tesla client.
  Optional `config` argument sets the following values at runtime:
  - Base URL
  - API Key
  - `Tesla.Adapter`
  - `Tesla.Middleware`
  - HTTP options for selected `Tesla.Adapter`
  Example
  ```
  config = %{
    base_url: "https://api.datadoghq.com",
    api_key: "some-api-key",
    adapter: Tesla.Adapter.Httpc,
    middleware: [Tesla.Middleware.Logger],
    http_options: [recv_timeout: 10_000]
  }
  client = Client.new(config)
  ```
  """
  @spec new(map) :: Tesla.Client.t()
  def new(config \\ %{}) do
    middleware = [
      {Tesla.Middleware.BaseUrl, get_base_url(config) <> "/api"},
      {Tesla.Middleware.Headers,
       [
         {"Content-Type", "application/json"},
         {"DD-API-KEY", get_api_key(config)}
       ]},
      Tesla.Middleware.JSON
    ]

    adapter = {get_adapter(config), get_http_options(config)}

    Tesla.client(middleware, adapter)
  end

  defp get_base_url(config) do
    case config[:base_url] || Application.get_env(:datadog_http, :base_url) do
      nil ->
        raise DatadogHttp.MissingBaseUrlError

      base_url ->
        base_url
    end
  end

  defp get_api_key(config) do
    case config[:api_key] || Application.get_env(:datadog_http, :api_key) do
      nil ->
        raise DatadogHttp.MissingAPIKeyError

      api_key ->
        api_key
    end
  end

  defp get_adapter(config) do
    config[:adapter] || Application.get_env(:datadog_http, :adapter) || Tesla.Adapter.Hackney
  end

  defp get_http_options(config) do
    Keyword.merge(
      Application.get_env(:datadog_http, :http_options, []),
      config[:http_options] || []
    )
  end
end
