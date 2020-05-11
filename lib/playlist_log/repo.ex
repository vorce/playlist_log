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
    with %{} = log <- CubDB.get(@cubdb, key(module, id), :no_such_log),
         {:ok, events} <- all(Event, log.id) do
      Logger.debug("Fetched events for log: #{length(events)}")
      {:ok, %Log{to_struct(module, log) | events: events, event_count: length(events)}}
    else
      :no_such_log -> {:error, {:no_such_resource, id}}
    end
  end

  def all(Log = module, id) do
    with {:ok, results} <- CubDB.select(@cubdb, select_keys(module, id)) do
      {:ok, Enum.map(results, fn {_key, match} -> to_struct(module, match) end)}
    end
  end

  def all(Event = module, id) do
    with {:ok, matches} <- CubDB.select(@cubdb, select_keys(module, id)) do
      result =
        Enum.flat_map(matches, fn {_k, events} -> Enum.map(events, &to_struct(module, &1)) end)

      {:ok, result}
    end
  end

  defp to_struct(Log = _module, %Log{} = struct), do: struct
  defp to_struct(Event = _module, %Event{} = struct), do: struct

  defp to_struct(Log = _module, %{tracks: tracks} = map) when is_list(tracks) do
    s = struct(Log, map)
    %Log{s | tracks: Enum.map(s.tracks, &to_struct(PlaylistLog.Playlists.Track, &1))}
  end

  defp to_struct(module, %{} = result) do
    struct(module, result)
  end

  defp to_map(%Log{tracks: tracks} = log) when is_list(tracks) do
    %{Map.from_struct(log) | tracks: Enum.map(log.tracks, &to_map/1)}
  end

  defp to_map(%{__struct__: _} = struct), do: Map.from_struct(struct)
  defp to_map(map) when is_map(map), do: map

  def update(Log = module, user_id, logs, update_fn) when is_list(logs) do
    Enum.each(logs, fn log ->
      key = key(module, {user_id, log.id})
      CubDB.update(@cubdb, key, log, fn existing -> update_fn.(existing, log) end)
    end)
  end

  def insert(Log = module, user_id, logs) do
    Enum.each(logs, fn log ->
      CubDB.put(@cubdb, key(module, {user_id, log.id}), to_map(log))
    end)
  end

  def insert(Event = module, log_id, %Ecto.Changeset{valid?: true} = changeset) do
    event =
      changeset
      |> Ecto.Changeset.apply_changes()
      |> to_map()

    key = key(module, {log_id, DateTime.to_date(event.timestamp)})
    Logger.info("Adding event from changeset #{inspect(key: key, value: event)}")

    CubDB.update(@cubdb, key, [event], fn existing ->
      [event | existing]
    end)
  end

  def insert(Event = module, log_id, %Event{} = event) do
    key = key(module, {log_id, DateTime.to_date(event.timestamp)})
    event = to_map(event)
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
    max_key = key(Log, {user_id, "zzzzzzzzzzzzzzzzzzzzzz"})
    [min_key: min_key, max_key: max_key]
  end

  def key(Log, {user_id, log_id}), do: {:log, user_id, log_id}
  def key(Event, {log_id, date}), do: {:event, log_id, Date.to_iso8601(date, :basic)}
end
