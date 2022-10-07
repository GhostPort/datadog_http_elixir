defmodule DatadogHttp.Events do
  @moduledoc """
  Functions for Datadog events endpoints.
  """

  alias DatadogHttp.Client

  @type config :: %{required(atom) => String.t() | keyword}
  @type error :: {:error, [String.t()]} | {:error, any()} | :error

  defmodule Event do
    @moduledoc """
    Datadog event data structure.
    """

    @type alert_type ::
            :error | :warning | :info | :success | :user_update | :recommendation | :snapshot
    @type event_priority :: :normal | :low

    defstruct [
      :text,
      :title,
      id: nil,
      id_str: nil,
      aggregation_key: nil,
      alert_type: nil,
      date_happened: nil,
      device_name: nil,
      host: nil,
      priority: nil,
      related_event_id: nil,
      source_type_name: nil,
      tags: []
    ]

    use ExConstructor

    @type t :: %__MODULE__{
            aggregation_key: String.t(),
            alert_type: alert_type,
            date_happened: integer | DateTime,
            device_name: String.t(),
            host: String.t(),
            id: integer(),
            id_str: String.t(),
            priority: event_priority,
            related_event_id: integer,
            source_type_name: String.t(),
            tags: [String.t()],
            text: String.t(),
            title: String.t()
          }

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(%{date_happened: %DateTime{} = date_happened} = value, opts) do
        __MODULE__.encode(%{value | date_happened: DateTime.to_unix(date_happened)}, opts)
      end

      def encode(value, opts) do
        alert_type_string = if value.alert_type, do: Atom.to_string(value.alert_type)
        priority_string = if value.priority, do: Atom.to_string(value.priority)

        value
        |> Map.merge(%{
          alert_type: alert_type_string,
          priority: priority_string
        })
        |> Map.delete(:__struct__)
        |> Jason.Encode.map(opts)
      end
    end
  end

  defp map_event(body_event) do
    alert_type =
      if body_event["alert_type"],
        do: String.to_existing_atom(body_event["alert_type"]),
        else: nil

    priority =
      if body_event["priority"], do: String.to_existing_atom(body_event["priority"]), else: nil

    date_happened =
      if body_event["date_happened"],
        do: DateTime.from_unix!(body_event["date_happened"]),
        else: nil

    Event.new(body_event)
    |> Map.merge(%{
      alert_type: alert_type,
      priority: priority,
      date_happened: date_happened
    })
  end

  @spec post(Event) :: {:ok, Event.t()} | error
  def post(event, config \\ %{}) do
    c = config[:client] || Client.new(config)

    case Tesla.post(c, "/v1/events", event) do
      {:ok, %{status: status, body: %{"errors" => errors}}}
      when status >= 400 and is_list(errors) ->
        {:error, errors}

      {:ok, %{status: 202, body: %{"event" => event}}} ->
        {:ok, map_event(event)}

      {:error, reason} ->
        {:error, reason}

      _ ->
        :error
    end
  end
end
