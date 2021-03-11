defmodule PlaylistLog.LogStatsTest do
  use ExUnit.Case

  alias PlaylistLog.LogStats
  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log

  @user_id "logstatstest"

  describe "top_artists/2" do
    test "returns top artists" do
      log_id = "stats-top_artists"

      events =
        [{1, "David Bowie"}, {4, "SOPHIE"}, {2, "MF DOOM"}]
        |> Enum.reduce([], fn {c, artist}, acc ->
          acc ++ Enum.map(1..c, &event(&1, log_id, artist))
        end)

      log = %Log{log(log_id, @user_id) | events: events, track_count: 0}

      assert LogStats.top_artists(log, 2) == %{
               data: [2, 4],
               labels: ["MF DOOM", "SOPHIE"]
             }
    end
  end

  describe "days_in_list/1" do
    test "returns map with min, avg, and max in days" do
      log_id = "stats-days_in_list"
      log = %Log{log(log_id, @user_id) | events: events(log_id), track_count: 1}

      assert LogStats.days_in_list(log) == %{
               min: 2.21,
               avg: 5.42,
               max: 14.04
             }
    end
  end

  describe "added_dates/1" do
    test "returns dates and the number of additions on that date" do
      log_id = "stats-added_dates"
      log = %Log{log(log_id, @user_id) | events: events(log_id), track_count: 1}

      assert LogStats.added_dates(log) == [
               %{x: "2021-02-15", y: 1},
               %{x: "2021-02-16", y: 0},
               %{x: "2021-02-17", y: 0},
               %{x: "2021-02-18", y: 0},
               %{x: "2021-02-19", y: 0},
               %{x: "2021-02-20", y: 0},
               %{x: "2021-02-21", y: 0},
               %{x: "2021-02-22", y: 0},
               %{x: "2021-02-23", y: 0},
               %{x: "2021-02-24", y: 0},
               %{x: "2021-02-25", y: 0},
               %{x: "2021-02-26", y: 0},
               %{x: "2021-02-27", y: 0},
               %{x: "2021-02-28", y: 0},
               %{x: "2021-03-01", y: 2}
             ]
    end
  end

  test "added_times/1" do
    log_id = "stats-added_times"
    log = %Log{log(log_id, @user_id) | events: events(log_id), track_count: 1}

    assert LogStats.added_times(log) == [
             %{x: "2021-01-01T00:00:00Z", y: 0},
             %{x: "2021-01-01T01:00:00Z", y: 0},
             %{x: "2021-01-01T02:00:00Z", y: 0},
             %{x: "2021-01-01T03:00:00Z", y: 0},
             %{x: "2021-01-01T04:00:00Z", y: 0},
             %{x: "2021-01-01T05:00:00Z", y: 0},
             %{x: "2021-01-01T06:00:00Z", y: 0},
             %{x: "2021-01-01T07:00:00Z", y: 0},
             %{x: "2021-01-01T08:00:00Z", y: 0},
             %{x: "2021-01-01T09:00:00Z", y: 0},
             %{x: "2021-01-01T10:00:00Z", y: 0},
             %{x: "2021-01-01T11:00:00Z", y: 0},
             %{x: "2021-01-01T12:00:00Z", y: 1},
             %{x: "2021-01-01T13:00:00Z", y: 2},
             %{x: "2021-01-01T14:00:00Z", y: 0},
             %{x: "2021-01-01T15:00:00Z", y: 0},
             %{x: "2021-01-01T16:00:00Z", y: 0},
             %{x: "2021-01-01T17:00:00Z", y: 0},
             %{x: "2021-01-01T18:00:00Z", y: 0},
             %{x: "2021-01-01T19:00:00Z", y: 0},
             %{x: "2021-01-01T20:00:00Z", y: 0},
             %{x: "2021-01-01T21:00:00Z", y: 0},
             %{x: "2021-01-01T22:00:00Z", y: 0},
             %{x: "2021-01-01T23:00:00Z", y: 0}
           ]
  end

  defp event(id, log_id, artist) do
    %Event{
      id: id,
      timestamp: DateTime.utc_now(),
      type: "TRACK_ADDED",
      user: id,
      log_id: log_id,
      track_uri: id,
      track_name: id,
      track_artist: artist
    }
  end

  defp events(log_id) do
    [
      %Event{
        id: "3",
        timestamp: DateTime.from_naive!(~N[2021-02-15T12:16:15Z], "Etc/UTC"),
        type: "TRACK_ADDED",
        user: "a",
        log_id: log_id,
        track_uri: "3",
        track_name: "3",
        track_artist: "3"
      },
      %Event{
        id: "1",
        timestamp: DateTime.from_naive!(~N[2021-03-01T13:15:05Z], "Etc/UTC"),
        type: "TRACK_ADDED",
        user: "a",
        log_id: log_id,
        track_uri: "1",
        track_name: "1",
        track_artist: "1"
      },
      %Event{
        id: "2",
        timestamp: DateTime.from_naive!(~N[2021-03-01T13:16:05Z], "Etc/UTC"),
        type: "TRACK_ADDED",
        user: "a",
        log_id: log_id,
        track_uri: "2",
        track_name: "2",
        track_artist: "2"
      },
      %Event{
        id: "3",
        timestamp: DateTime.from_naive!(~N[2021-03-01T13:16:15Z], "Etc/UTC"),
        type: "TRACK_REMOVED",
        user: "a",
        log_id: log_id,
        track_uri: "3",
        track_name: "3",
        track_artist: "3"
      },
      %Event{
        id: "2",
        timestamp: DateTime.from_naive!(~N[2021-03-03T18:16:05Z], "Etc/UTC"),
        type: "TRACK_REMOVED",
        user: "a",
        log_id: log_id,
        track_uri: "2",
        track_name: "2",
        track_artist: "2"
      }
    ]
  end

  defp log(id, owner) do
    Log.new(%{"id" => id, "name" => id, "owner" => %{"id" => owner}})
  end
end
