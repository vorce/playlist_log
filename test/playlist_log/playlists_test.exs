defmodule PlaylistLog.PlaylistsTest do
  use ExUnit.Case
  alias PlaylistLog.Playlists
  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track
  alias PlaylistLog.Test.SpotifyStubClient

  @user_id "user_1"

  describe "list_playlists/2" do
    test "returns list of playlists from music platform" do
      user = %{"id" => SpotifyStubClient.user()}

      assert {:ok, result} = Playlists.list_playlists(user, "token")
      assert length(result) == 1

      first_list = hd(result)
      assert first_list.fetched_by == first_list.owner_id
      assert first_list.fetched_by == user["id"]
      assert first_list.track_count == 30
    end

    test "returns error tuple if music platform fails" do
      user = %{"id" => SpotifyStubClient.user()}

      assert {:error, {_, _}} = Playlists.list_playlists(user, "fail")
    end
  end

  describe "list_logs/1" do
    test "returns existing logs" do
      user_id = "bob"
      user = %{"id" => user_id}
      expected = [log("1", user_id), log("2", user_id)]
      PlaylistLog.Repo.insert(Log, user_id, expected)

      assert {:ok, actual} = Playlists.list_logs(user)
      assert length(actual) == length(expected)
      assert Enum.map(actual, fn l -> l.id end) == Enum.map(expected, fn l -> l.id end)
    end

    test "returns empty list for a user without any logs" do
      user = %{"id" => "someuserthatdidnotcreateanylist"}

      assert {:ok, []} == Playlists.list_logs(user)
    end
  end

  describe "get_log/3" do
    setup do
      PlaylistLog.Repo.delete(Log, {@user_id, "many-events"})
      :ok
    end

    test "returns an error tuple if log does not exist" do
      user = %{"id" => "user"}

      assert Playlists.get_log(user, "unknown-log-id", "token") ==
               {:error, {:no_such_resource, {"user", "unknown-log-id"}}}
    end

    test "return log" do
      user = %{"id" => @user_id}
      expected = [%Log{log("1", @user_id) | events: [], track_count: 0}]
      PlaylistLog.Repo.insert(Log, @user_id, expected)

      assert {:ok, %PlaylistLog.Playlists.Log{track_count: 2, event_count: 2}} =
               Playlists.get_log(user, "1", "token")
    end

    test "returns only the first 30 events from storage" do
      log_id = "many-events"
      user = %{"id" => @user_id}
      # this comes from the mocked playlist
      events_from_spotify = 2
      events_from_storage = 30
      events_in_storage = 0..100 |> Enum.map(&event(&1, log_id))

      Enum.each(events_in_storage, &PlaylistLog.Repo.insert(Event, log_id, &1))

      expected = [%Log{log(log_id, @user_id) | events: events_in_storage, track_count: 0}]
      PlaylistLog.Repo.insert(Log, @user_id, expected)

      {:ok, log} = Playlists.get_log(user, log_id, "token", max_events: events_from_storage)

      assert length(log.events) == events_from_storage + events_from_spotify
    end

    test "does not add duplicate TRACK_ADDED events" do
      # log with more events than tracks in playlist
      log_id = "no-duplicate-TRACK_ADDED"
      user = %{"id" => @user_id}
      events_in_storage = 1..35 |> Enum.map(&event(&1, log_id))

      # This event will be in storage, AND will also be an event based on the
      # playlist from spotify.
      existing_event = %PlaylistLog.Playlists.Event{
        id: nil,
        log_id: log_id,
        timestamp: ~U[2016-10-11 13:44:40Z],
        track_artist: "Zion & Lennox, J Balvin",
        track_name: "Otra Vez (feat. J Balvin)",
        track_uri: "spotify:track:7pk3EpFtmsOdj8iUhjmeCM",
        type: "TRACK_ADDED",
        user: "spotify_españa"
      }

      events_in_storage = [existing_event | events_in_storage]

      Enum.each(events_in_storage, &PlaylistLog.Repo.insert(Event, log_id, &1))
      log = %Log{log(log_id, @user_id) | events: events_in_storage, track_count: 0}
      PlaylistLog.Repo.insert(Log, @user_id, [log])

      assert length(log.events) == length(events_in_storage)

      # get_log triggers additions of any events it thinks is missing from the event store.
      {:ok, _get_log} = Playlists.get_log(user, log_id, "token")

      {:ok, all_events} =
        PlaylistLog.Repo.all(PlaylistLog.Playlists.Event, log_id, max_events: 10_000)

      events_for_existing =
        Enum.filter(all_events, fn e ->
          e.track_uri == existing_event.track_uri && e.timestamp == existing_event.timestamp &&
            e.type == existing_event.type
        end)

      assert length(events_for_existing) == 1
    end
  end

  describe "delete_tracks/5" do
    test "returns map of deleted tracks" do
      user_id = "user_2"
      user = %{"id" => user_id}

      tracks = [track("1", "one"), track("2", "two"), track("3", "three")]

      existing_log = %Log{
        log("user_2", user_id)
        | tracks: tracks,
          track_count: length(tracks),
          events: [],
          event_count: 0
      }

      PlaylistLog.Repo.insert(Log, user_id, [existing_log])

      result =
        Playlists.delete_tracks(user, existing_log.id, "snapshot_id", ["1", "2"], "access_token")

      assert result ==
               {:ok,
                %{
                  "1" => %{artist: "artist_one", name: "one", uri: "1"},
                  "2" => %{artist: "artist_two", name: "two", uri: "2"}
                }}

      {:ok, log_after} = PlaylistLog.Repo.get(Log, {user_id, user_id})
      assert log_after.track_count == 1
    end
  end

  describe "add_track/3" do
    test "returns track info on success" do
      uri = "spotify:track:1"
      user_id = "user_3"

      existing_log = %Log{
        log(user_id, user_id)
        | tracks: [],
          track_count: 0,
          events: [],
          event_count: 0
      }

      PlaylistLog.Repo.insert(Log, user_id, [existing_log])

      assert {:ok,
              %{
                artist: _,
                name: _,
                uri: ^uri
              }} = Playlists.add_track(existing_log, uri, "token")
    end
  end

  defp log(id, owner) do
    Log.new(%{"id" => id, "name" => id, "owner" => %{"id" => owner}})
  end

  defp track(uri, name) do
    %Track{uri: uri, name: name, artists: [%{"name" => "artist_#{name}"}]}
  end

  defp event(id, log_id) do
    %Event{
      id: id,
      timestamp: DateTime.utc_now(),
      type: "TRACK_ADDED",
      user: id,
      log_id: log_id,
      track_uri: id,
      track_name: id,
      track_artist: id
    }
  end
end
