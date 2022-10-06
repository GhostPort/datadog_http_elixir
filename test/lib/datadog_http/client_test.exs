defmodule DatadogHttp.ClientTest do
  use ExUnit.Case

  alias DatadogHttp.Client

  @moduletag :client

  describe "client new/1" do
    @describetag :unit

    setup do
      on_exit(fn ->
        Application.delete_env(:datadog_http, :api_key)
      end)
    end

    test "base url" do
      # raise when base URL is nil
      Application.put_env(:datadog_http, :base_url, nil)
      Application.put_env(:datadog_http, :api_key, "irrelevant-api-key")

      assert_raise DatadogHttp.MissingBaseUrlError, fn ->
        Client.new()
      end

      # use the application environment variable
      Application.put_env(:datadog_http, :base_url, "https://environment-base-url")

      client = Client.new()

      assert Enum.member?(
               client.pre,
               {Tesla.Middleware.BaseUrl, :call, ["https://environment-base-url/api"]}
             )

      # runtime config overrides app env
      client = Client.new(%{base_url: "https://config-base-url"})

      assert Enum.member?(
               client.pre,
               {Tesla.Middleware.BaseUrl, :call, ["https://config-base-url/api"]}
             )
    end

    test "API key" do
      # raise when API key is not provided
      assert_raise DatadogHttp.MissingAPIKeyError, fn ->
        Client.new()
      end

      # use the application environment variable
      Application.put_env(:datadog_http, :api_key, "env-api-key")

      client = Client.new()

      assert Enum.find(client.pre, fn
               {Tesla.Middleware.Headers, _, [headers]} ->
                 Enum.member?(headers, {"DD-API-KEY", "env-api-key"})

               _ ->
                 false
             end),
             "API key should match the application environment variable value"

      # runtime config overrides app env
      Application.put_env(:datadog_http, :api_key, "env-api-key")

      client = Client.new(%{api_key: "config-api-key"})

      assert Enum.find(client.pre, fn
               {Tesla.Middleware.Headers, _, [headers]} ->
                 Enum.member?(headers, {"DD-API-KEY", "config-api-key"})

               _ ->
                 false
             end),
             "API key should match the configuration dictionary value"
    end
  end
end
