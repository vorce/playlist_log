defmodule PlaylistLog.Migrations.RemoveDuplicateEvents do
  @moduledoc """
  A lot of old duplicates that was caused by a bug https://github.com/vorce/playlist_log/issues/30
  which was most likely introduced in https://github.com/vorce/playlist_log/pull/22
  """

  @doc """
  Removes duplicate events from a specific log, going back `max_days_back`
  """
  def run() do
    max_days_back = 548
    playlist_id = "3AecNkQNg9GhbYLV9G3z85"

    Enum.map(0..max_days_back, fn days_back ->
      DateTime.utc_now()
      |> DateTime.add(-(60 * 60 * 24 * days_back), :second)
      |> DateTime.to_date()
    end)
    |> Enum.map(fn day ->
      PlaylistLog.Repo.key(PlaylistLog.Playlists.Event, {playlist_id, day})
    end)
    |> Enum.filter(&CubDB.has_key?(:cubdb, &1))
    |> Enum.each(fn key ->
      CubDB.update(:cubdb, key, [], fn existing ->
        Enum.uniq_by(existing, fn e -> {e.timestamp, e.type, e.track_artist, e.track_name} end)
      end)
    end)
  end
end
