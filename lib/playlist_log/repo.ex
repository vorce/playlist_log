defmodule PlaylistLog.Repo do
  @moduledoc """
  Takes on the same role as an Ecto Repo although it is not strictly one.
  """

  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log

  @early_date ~D[1985-03-13]
  @cubdb :cubdb

  def get(Log = module, id) do
    with %Log{} = log <- CubDB.get(@cubdb, key(module, id), :no_such_log),
         {:ok, events} <- CubDB.select(@cubdb, select_keys(Event, log.id)) do
      {:ok, %Log{log | events: events, event_count: length(events)}}
    else
      :no_such_log -> {:error, {:no_such_resource, id}}
    end
  end

  def get(Event = module, log_id) do
    CubDB.select(@cubdb, select_keys(module, log_id))
  end

  def insert(Log = module, user_id, logs) do
    Enum.each(logs, fn log -> CubDB.put(@cubdb, key(module, {user_id, log.id}), log) end)
  end

  def select_keys(PlaylistLog.Playlists.Event, log_id) do
    prefix = :event
    min_key = {prefix, log_id, @early_date}
    max_key = {prefix, log_id, Date.add(Date.utc_today(), 1)}
    [min_key: min_key, max_key: max_key]
  end

  def key(PlaylistLog.Playlists.Log, {user_id, log_id}), do: {:log, user_id, log_id}
end
