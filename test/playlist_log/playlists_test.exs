defmodule PlaylistLog.PlaylistsTest do
  use ExUnit.Case
  alias PlaylistLog.Playlists
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Test.SpotifyStubClient

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
    test "returns an error tuple if log does not exist" do
      user = %{"id" => "user"}

      assert Playlists.get_log(user, "unknown-log-id", "token") ==
               {:error, {:no_such_resource, {"user", "unknown-log-id"}}}
    end

    test "return log" do
      user_id = "user_1"
      user = %{"id" => user_id}
      expected = [%Log{log("1", user_id) | events: [], track_count: 0}]
      PlaylistLog.Repo.insert(Log, user_id, expected)

      assert {:ok, %PlaylistLog.Playlists.Log{track_count: 2, event_count: 2}} =
               Playlists.get_log(user, "1", "token")
    end
  end

  defp log(id, owner) do
    Log.new(%{"id" => id, "name" => id, "owner" => %{"id" => owner}})
  end
end
