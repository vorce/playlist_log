defmodule PlaylistLog.PlaylistsTest do
  use ExUnit.Case
  alias PlaylistLog.Playlists

  describe "list_playlists/2" do
    test "returns list of playlists from music platform" do
      user = %{"id" => PlaylistLog.Test.SpotifyStubClient.user()}

      assert {:ok, result} = Playlists.list_playlists(user, "token")
      assert length(result) == 1

      first_list = hd(result)
      assert first_list.fetched_by == first_list.owner_id
      assert first_list.fetched_by == user["id"]
      assert first_list.track_count == 30
    end
  end
end
