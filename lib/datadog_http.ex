defmodule DatadogHttp do
  @moduledoc """
  A client for Datadog's HTTP API, useful for building integrations.

  [Datadog API reference](https://docs.datadoghq.com/api/latest/)
  """

  defmodule MissingAPIKeyError do
    defexception message: """
                 An `api_key` is required for calls to Datadog.
                 Configure `api_key` in your config.exs file or pass it into the function via the `config` argument.

                 config :datadog_http, api_key: "your_api_key"
                 """
  end

  defmodule MissingBaseUrlError do
    defexception message: """
                 The `base_url` is required for calls to Datadog.
                 Configure `base_url` in your config.exs file or pass it into the function via the `config` argument.

                 By default, this is set to "https://api.datadoghq.com".

                 For help finding your Datadog base URL subdomain, check out the related Datadog documentation (https://docs.datadoghq.com/getting_started/site/#access-the-datadog-site)

                 config :datadog_http, base_url: "https://api.datadoghq.eu"
                 """
  end
end
