defmodule PlaylistLogWeb.LogControllerTest do
  use PlaylistLogWeb.ConnCase, async: false

  import Mock

  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track
  alias PlaylistLog.Repo

  describe "add_track/2" do
    test "remove_oldest", %{conn: conn} do
      log_id = "test-remove-oldest-track"
      user_id = "vdon"
      added_at = DateTime.from_naive!(~N[2020-05-07 10:00:00], "Etc/UTC")
      oldest_track = track("2", DateTime.add(added_at, -3600))

      log = %Log{
        id: log_id,
        name: "da playlist",
        external_id: log_id,
        collaborative: false,
        owner_id: user_id,
        snapshot_id: "snapshot1",
        tracks: [
          track("1", added_at),
          oldest_track,
          track("3", DateTime.add(added_at, 3600))
        ]
      }

      :ok = Repo.insert(Log, user_id, [log])

      add_track_params = %{"uri" => "4", "remove_oldest" => true}

      with_mock spotify_client(),
        get_playlist_tracks: spotify_tracks(log.tracks),
        get_track: spotify_track(add_track_params["uri"]),
        add_tracks_to_playlist: fn _, _, _ -> {:ok, "snapshot2"} end,
        delete_tracks_from_playlist: fn _, _, "snapshot2", _ -> {:ok, "snapshot3"} end do
        conn =
          conn
          |> assign(:spotify, :no_refresh)
          |> put_resp_cookie("spotify_access_token", "faketoken")
          |> put_resp_cookie("spotify_refresh_token", "fakerefreshtoken")
          |> init_test_session(%{spotify_user: %{"id" => user_id}})
          |> post(Routes.log_path(conn, :add_track, log_id, track: add_track_params))

        assert %{id: id} = redirected_params(conn)
        assert redirected_to(conn) == Routes.log_path(conn, :show, id)

        {:ok, log} = Repo.get(Log, {user_id, log_id})
        assert log.track_count == 3

        assert_called(
          spotify_client().delete_tracks_from_playlist(:_, log_id, "snapshot2", [oldest_track.uri])
        )
      end
    end
  end

  defp track(id, added_at) do
    %Track{id: id, name: id, uri: id, added_at: added_at, artists: [%{"name" => "artist#{id}"}]}
  end

  defp spotify_client() do
    Application.get_env(:playlist_log, PlaylistLog.Playlists)[:spotify_client]
  end

  defp spotify_track(uri) do
    fn _, _ ->
      {:ok,
       %{
         "name" => "test track",
         "album" => %{},
         "artists" => [],
         "id" => uri,
         "uri" => uri,
         "type" => "track"
       }}
    end
  end

  defp spotify_tracks(tracks) do
    spotify_tracks =
      Enum.map(tracks, fn t ->
        %{
          "added_at" => DateTime.to_iso8601(t.added_at),
          "added_by" => %{
            "id" => t.added_by
          },
          "track" => %{
            "uri" => t.id,
            "id" => t.uri,
            "name" => t.name,
            "artists" => t.artists
          }
        }
      end)

    fn _token, _id ->
      {:ok, spotify_tracks}
    end
  end
end
