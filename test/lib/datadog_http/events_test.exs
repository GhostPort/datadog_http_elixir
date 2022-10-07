defmodule DatadogHttp.EventsTest do
  use ExUnit.Case

  alias DatadogHttp.Events

  @moduletag :events

  setup do
    bypass = Bypass.open()
    config = %{api_key: "some_key", base_url: "http://localhost:#{bypass.port}"}

    %{bypass: bypass, config: config}
  end

  describe "post" do
    @describetag :unit

    test "documentation example success", %{bypass: bypass, config: config} do
      event = %Events.Event{
        title: "Example-Post_an_event_returns_OK_response",
        text: "A text message.",
        tags: [
          "test:ExamplePostaneventreturnsOKresponse"
        ]
      }

      response_event = Map.merge(event, %{id: 123, id_str: "123"})

      Bypass.expect(bypass, "POST", "/api/v1/events", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        body = Jason.decode!(body, keys: :atoms)

        assert %{
                 title: "Example-Post_an_event_returns_OK_response",
                 text: "A text message.",
                 tags: [
                   "test:ExamplePostaneventreturnsOKresponse"
                 ]
               } = body

        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(202, Jason.encode!(%{event: response_event}))
      end)

      assert {:ok, ^response_event} = Events.post(event, config)
    end

    test "Datetime and atom success", %{bypass: bypass, config: config} do
      event = %Events.Event{
        title: "Example-Post_an_event_returns_OK_response",
        text: "A text message.",
        date_happened: ~U[2022-01-01 00:00:00Z],
        alert_type: :error,
        priority: :low
      }

      response_event = Map.merge(event, %{id: 123, id_str: "123"})

      Bypass.expect(bypass, "POST", "/api/v1/events", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        body = Jason.decode!(body, keys: :atoms)

        assert %{
                 date_happened: 1_640_995_200,
                 alert_type: "error",
                 priority: "low"
               } = body

        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(202, Jason.encode!(%{event: response_event}))
      end)

      assert {:ok, ^response_event} = Events.post(event, config)
    end

    test "error response", %{bypass: bypass, config: config} do
      event = %Events.Event{}

      Bypass.expect(bypass, "POST", "/api/v1/events", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(400, Jason.encode!(%{errors: ["Bad Request"]}))
      end)

      assert {:error, ["Bad Request"]} = Events.post(event, config)
    end

    test "error" do
      event = %Events.Event{}
      config = %{api_key: "some_key", base_url: "nope"}

      assert {:error, :nxdomain} = Events.post(event, config)
    end

    test "malformed_response", %{bypass: bypass, config: config} do
      event = %Events.Event{}

      Bypass.expect(bypass, "POST", "/api/v1/events", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{bad: "response"}))
      end)

      assert :error = Events.post(event, config)
    end
  end
end
