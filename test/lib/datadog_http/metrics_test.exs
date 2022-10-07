defmodule DatadogHttp.MetricsTest do
  use ExUnit.Case

  alias DatadogHttp.Metrics

  @moduletag :metrics

  setup do
    bypass = Bypass.open()
    config = %{api_key: "some_key", base_url: "http://localhost:#{bypass.port}"}

    %{bypass: bypass, config: config}
  end

  describe "submit" do
    @describetag :unit

    test "no metrics success", %{bypass: bypass, config: config} do
      Bypass.expect(bypass, "POST", "/api/v2/series", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert %{series: []} = Jason.decode!(body, keys: :atoms)

        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(202, Jason.encode!(%{errors: []}))
      end)

      assert :ok = Metrics.submit([], config)
    end

    test "documentation example success", %{bypass: bypass, config: config} do
      metric = %Metrics.Metric{
        metric: "system.load1",
        type: 0,
        points: [
          %Metrics.Point{
            timestamp: 1_636_629_071,
            value: 0.7
          }
        ],
        resources: [
          %Metrics.Resource{
            name: "dummyhost",
            type: "host"
          }
        ]
      }

      Bypass.expect(bypass, "POST", "/api/v2/series", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        body = Jason.decode!(body, keys: :atoms)

        assert length(body.series) == 1

        assert %{
                 metric: "system.load1",
                 type: 0,
                 points: [
                   %{
                     timestamp: 1_636_629_071,
                     value: 0.7
                   }
                 ],
                 resources: [
                   %{
                     name: "dummyhost",
                     type: "host"
                   }
                 ]
               } = Enum.at(body.series, 0)

        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(202, Jason.encode!(%{errors: []}))
      end)

      assert :ok = Metrics.submit([metric], config)
    end

    test "DateTime objects are converted into unix second timestamps", %{
      bypass: bypass,
      config: config
    } do
      metric = %Metrics.Metric{
        metric: "something.measured",
        points: [
          %Metrics.Point{
            timestamp: ~U[2022-01-01 00:00:00Z],
            value: 4.2
          }
        ]
      }

      Bypass.expect(bypass, "POST", "/api/v2/series", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        body = Jason.decode!(body, keys: :atoms)

        assert length(body.series) == 1

        assert %{
                 metric: "something.measured",
                 points: [
                   %{
                     timestamp: 1_640_995_200,
                     value: 4.2
                   }
                 ]
               } = Enum.at(body.series, 0)

        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(202, Jason.encode!(%{errors: []}))
      end)

      assert :ok = Metrics.submit([metric], config)
    end

    test "error response", %{bypass: bypass, config: config} do
      Bypass.expect(bypass, "POST", "/api/v2/series", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(400, Jason.encode!(%{errors: ["Bad Request"]}))
      end)

      assert {:error, ["Bad Request"]} = Metrics.submit([], config)
    end
  end
end
