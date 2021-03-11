defmodule PlaylistLog.LogStats do
  @moduledoc """
  Statistics for a log

  Example usage:

      log_id = "abc123"
      username = "koolbeans"
      {:ok, log} = PlaylistLog.Repo.get(Log, {username, log_id}, max_events: 50_000)
      PlaylistLog.LogStats.top_artists(log)

  """

  @doc """
  Returns the artists which has had the most tracks in the playlist.
  """
  def top_artists(log, max \\ 10) do
    log.events
    |> Enum.filter(fn e -> e.type == "TRACK_ADDED" end)
    |> Enum.frequencies_by(fn e -> e.track_artist end)
    |> Enum.sort_by(fn {_artist, freq} -> freq end, :desc)
    |> Enum.take(max)
    |> Enum.reduce(%{labels: [], data: []}, &chart_format/2)
  end

  defp chart_format({artist, freq}, acc) do
    %{labels: [artist | acc.labels], data: [freq | acc.data]}
  end

  @doc """
  Returns `%{min: min, avg: avg, max: max}` number of days a track is in the playlist.
  Assumes that a track has only ever been added/removed once from the list!
  """
  def days_in_list(log) do
    tracks = Enum.group_by(log.events, fn e -> e.track_uri end)
    stats = Enum.reduce(tracks, %{min: 99_999_999, avg: 0, max: 0}, &track_lifetime_seconds/2)

    %{
      min: seconds_to_days(stats.min),
      avg: seconds_to_days(stats.avg / map_size(tracks)),
      max: seconds_to_days(stats.max)
    }
  end

  # number of seconds active in the list (aka seconds between being added and removed)
  defp track_lifetime_seconds({_track, track_events}, acc) do
    added_event = Enum.find(track_events, fn e -> e.type == "TRACK_ADDED" end)
    removed_event = Enum.find(track_events, fn e -> e.type == "TRACK_REMOVED" end)

    if is_nil(added_event) || is_nil(removed_event) do
      # Don't account for tracks that has not been removed yet.
      acc
    else
      diff = DateTime.diff(removed_event.timestamp, added_event.timestamp)
      %{min: min(diff, acc.min), avg: diff + acc.avg, max: max(diff, acc.max)}
    end
  end

  @seconds_per_minute 60
  @minutes_per_hour 60
  @hours_per_day 24
  def seconds_to_days(seconds) do
    days = seconds / @seconds_per_minute / @minutes_per_hour / @hours_per_day
    Float.round(days, 2)
  end

  @doc """
  Returns a map date => nr of events
  """
  def added_dates(log) do
    log.events
    |> Enum.filter(fn e -> e.type == "TRACK_ADDED" end)
    |> Enum.frequencies_by(fn e -> DateTime.to_date(e.timestamp) end)
    |> missing_zero_dates()
    |> Enum.map(fn {date, freq} ->
      %{x: Date.to_iso8601(date), y: freq}
    end)
    |> Enum.sort_by(fn %{x: date} -> date end)
  end

  defp missing_zero_dates(event_dates) do
    {{min, _}, {max, _}} = Enum.min_max_by(event_dates, fn {date, _freq} -> date end, Date)

    diff_days = Date.diff(max, min)

    Enum.map(1..diff_days, fn offset ->
      {Date.add(min, offset), 0}
    end)
    |> Enum.reject(fn {date, _freq} -> Map.has_key?(event_dates, date) end)
    |> Enum.into(%{})
    |> Map.merge(event_dates)
  end

  @doc """
  Returns the frequency of each hour when updates were made
  Note: The date is just there to have something.
  """
  def added_times(log) do
    log.events
    |> Enum.filter(fn e -> e.type == "TRACK_ADDED" end)
    |> Enum.frequencies_by(fn e ->
      time = e.timestamp |> DateTime.to_time() |> Time.truncate(:second)
      time.hour
    end)
    |> missing_zero_hours()
    |> Enum.map(fn {hour, freq} ->
      %{x: "2021-01-01T#{padded_hour(hour)}:00:00Z", y: freq}
    end)
    |> Enum.sort_by(fn %{x: hour} -> hour end)
  end

  defp missing_zero_hours(event_hours) do
    Enum.map(0..23, fn hour ->
      {hour, 0}
    end)
    |> Enum.reject(fn {hour, _freq} -> Map.has_key?(event_hours, hour) end)
    |> Enum.into(%{})
    |> Map.merge(event_hours)
  end

  defp padded_hour(hour) when hour >= 10, do: "#{hour}"

  defp padded_hour(hour) do
    "0#{hour}"
  end
end
