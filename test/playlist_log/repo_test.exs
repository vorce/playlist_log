defmodule PlaylistLog.RepoTest do
  use ExUnit.Case

  alias PlaylistLog.Repo
  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track

  @event_time_stamp DateTime.from_naive!(~N[2020-05-10T13:37:00Z], "Etc/UTC")
  @event_log_id "event-logid-1"

  setup do
    CubDB.delete(:cubdb, Repo.key(Event, {@event_log_id, @event_time_stamp}))
  end

  describe "insert/3" do
    test "saves Log struct as map" do
      user_id = "user031"

      log = %Log{
        id: "daLog123",
        name: "foo",
        description: "",
        track_count: 0,
        external_id: "id",
        collaborative: false,
        owner_id: user_id,
        tracks: [%Track{name: "ye", uri: "uri", id: "id"}]
      }

      :ok = Repo.insert(Log, user_id, [log])

      log_from_storage = CubDB.get(:cubdb, Repo.key(Log, {user_id, log.id}))
      refute Map.has_key?(log_from_storage, :__struct__)
    end

    test "saves Event struct as map" do
      user_id = "user031-2"

      event = %Event{
        log_id: @event_log_id,
        timestamp: @event_time_stamp,
        type: "TRACK_ADDED",
        user: user_id,
        track_uri: "uri",
        track_name: "name",
        track_artist: "artist"
      }

      :ok = Repo.insert(Event, event.log_id, event)

      [event_from_storage] = CubDB.get(:cubdb, Repo.key(Event, {event.log_id, @event_time_stamp}))

      refute Map.has_key?(event_from_storage, :__struct__)
    end
  end

  describe "get/2" do
    test "can read Log when stored as map" do
      user_id = "user1"

      log = %Log{
        name: "foo",
        description: "",
        track_count: 0,
        external_id: "id",
        collaborative: false,
        owner_id: user_id
      }

      :ok = CubDB.put(:cubdb, Repo.key(Log, {user_id, "log_as_map"}), Map.from_struct(log))
      :ok = CubDB.put(:cubdb, Repo.key(Log, {user_id, "log_as_struct"}), log)

      {:ok, log_from_struct} = Repo.get(Log, {user_id, "log_as_struct"})
      {:ok, log_from_map} = Repo.get(Log, {user_id, "log_as_map"})

      assert log_from_map == log_from_struct
    end
  end

  describe "all/2" do
    test "can read Logs stored as maps" do
      user_id = "user2"

      log = %Log{
        name: "foo",
        description: "",
        track_count: 0,
        external_id: "id",
        collaborative: false,
        owner_id: user_id
      }

      :ok = CubDB.put(:cubdb, Repo.key(Log, {user_id, "Log_as_map1"}), Map.from_struct(log))
      :ok = CubDB.put(:cubdb, Repo.key(Log, {user_id, "Log_as_map2"}), Map.from_struct(log))

      {:ok, result} = Repo.all(Log, user_id)
      assert result == [log, log]
    end

    test "can read Events stored as maps" do
      log_id = "log_with_map_events"

      events = [
        %Event{
          log_id: log_id,
          timestamp: DateTime.utc_now(),
          type: "TRACK_REMOVED",
          user: "usr",
          track_uri: "uri",
          track_name: "tn",
          track_artist: "ta"
        },
        %Event{
          log_id: log_id,
          timestamp: DateTime.utc_now(),
          type: "TRACK_ADDED",
          user: "usr",
          track_uri: "uri2",
          track_name: "tn2",
          track_artist: "ta2"
        }
      ]

      event_maps = Enum.map(events, &Map.from_struct/1)
      key = Repo.key(Event, {log_id, DateTime.to_date(hd(events).timestamp)})
      :ok = CubDB.put(:cubdb, key, event_maps)

      {:ok, result} = Repo.all(Event, log_id)
      assert Enum.sort(result) == Enum.sort(events)
    end
  end
end
