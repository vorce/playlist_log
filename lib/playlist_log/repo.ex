defmodule PlaylistLog.Repo do
  @moduledoc """
  Takes on the same role as an Ecto Repo although it is not strictly one.
  """
  require Logger

  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log

  @early_date ~D[1985-03-13]
  @cubdb :cubdb

  def get(Log = module, id) do
    with %Log{} = log <- CubDB.get(@cubdb, key(module, id), :no_such_log),
         {:ok, events} <- all(Event, log.id) do
      Logger.debug("Fetched events for log: #{length(events)}")
      {:ok, %Log{log | events: events, event_count: length(events)}}
    else
      :no_such_log -> {:error, {:no_such_resource, id}}
    end
  end

  def all(Log = module, id) do
    with {:ok, results} <- CubDB.select(@cubdb, select_keys(module, id)) do
      {:ok, Enum.map(results, fn {_key, match} -> match end)}
    end
  end

  def all(Event = module, id) do
    with {:ok, matches} <- CubDB.select(@cubdb, select_keys(module, id)) do
      result =
        matches
        |> Enum.reduce([], fn {_k, events}, acc -> [events | acc] end)
        |> List.flatten()

      {:ok, result}
    end
  end

  def insert(Log = module, user_id, logs) do
    Enum.each(logs, fn log -> CubDB.put(@cubdb, key(module, {user_id, log.id}), log) end)
  end

  def insert(Event = module, log_id, %Ecto.Changeset{valid?: true} = changeset) do
    event = Ecto.Changeset.apply_changes(changeset)
    key = key(module, {log_id, DateTime.to_date(event.timestamp)})
    Logger.info("Adding event from changeset #{inspect(key: key, value: event)}")

    CubDB.update(@cubdb, key, [event], fn existing ->
      [event | existing]
    end)
  end

  def insert(Event = module, log_id, %Event{} = event) do
    key = key(module, {log_id, DateTime.to_date(event.timestamp)})
    Logger.info("Adding event #{inspect(key: key, value: event)}")

    CubDB.update(@cubdb, key, [event], fn existing ->
      [event | existing]
    end)
  end

  def update(%Ecto.Changeset{valid?: true} = changeset) do
    new_struct = Ecto.Changeset.apply_changes(changeset)
    do_update(new_struct.__struct__, new_struct)
  end

  defp do_update(Event, event) do
    insert(Event, event.log_id, event)
  end

  defp do_update(Log, log) do
    insert(Log, log.owner_id, [log])
  end

  def select_keys(Event, log_id) do
    min_key = key(Event, {log_id, @early_date})
    max_key = key(Event, {log_id, Date.add(Date.utc_today(), 1)})
    [min_key: min_key, max_key: max_key]
  end

  def select_keys(Log, user_id) do
    min_key = key(Log, {user_id, nil})
    max_key = key(Log, {user_id, "ZZZZZZZZZZZZZZZZZZZZZZ"})
    [min_key: min_key, max_key: max_key]
  end

  def key(Log, {user_id, log_id}), do: {:log, user_id, log_id}
  def key(Event, {log_id, date}), do: {:event, log_id, Date.to_iso8601(date, :basic)}
end
