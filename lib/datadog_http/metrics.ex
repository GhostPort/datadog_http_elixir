defmodule DatadogHttp.Metrics do
  @moduledoc """
  Functions for Datadog metrics endpoints.
  """

  alias DatadogHttp.Client

  @type config :: %{required(atom) => String.t() | keyword}
  @type error :: {:error, [String.t()]} | {:error, any()} | :error

  defmodule Metric do
    @moduledoc """
    Datadog metric data structure.
    """

    @derive Jason.Encoder
    defstruct interval: nil,
              metadata: nil,
              metric: nil,
              points: [],
              resources: [],
              source_type_name: nil,
              tags: [],
              type: nil,
              unit: nil

    @type t :: %__MODULE__{
            interval: integer(),
            metadata: map(),
            metric: String.t(),
            points: [DatadogHttp.Metrics.Point],
            resources: [DatadogHttp.Metrics.Resource],
            source_type_name: String.t(),
            tags: [String.t()],
            type: String.t(),
            unit: String.t()
          }
  end

  defmodule Point do
    @moduledoc """
    Datadog metric point data structure.
    """

    defstruct timestamp: nil,
              value: nil

    @type t :: %__MODULE__{
            timestamp: integer() | DateTime,
            value: float()
          }

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(%{timestamp: %DateTime{} = timestamp} = value, opts) do
        __MODULE__.encode(%{value | timestamp: DateTime.to_unix(timestamp)}, opts)
      end

      def encode(value, opts) do
        value
        |> Map.delete(:__struct__)
        |> Jason.Encode.map(opts)
      end
    end
  end

  defmodule Resource do
    @moduledoc """
    Datadog metric resource data structure.
    """

    @derive Jason.Encoder
    defstruct name: nil,
              type: nil

    @type t :: %__MODULE__{
            name: String.t(),
            type: String.t()
          }
  end

  @spec submit([Metric]) :: :ok | error
  def submit(metrics, config \\ %{}) do
    c = config[:client] || Client.new(config)

    case Tesla.post(c, "/v2/series", %{series: metrics}) do
      {:ok, %{status: status, body: %{"errors" => errors}}}
      when status >= 400 and is_list(errors) ->
        {:error, errors}

      {:ok, %{status: 202}} ->
        :ok

      {:error, reason} ->
        {:error, reason}

      _ ->
        :error
    end
  end
end
