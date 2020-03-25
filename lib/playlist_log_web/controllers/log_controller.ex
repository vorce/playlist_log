defmodule PlaylistLogWeb.LogController do
  use PlaylistLogWeb, :controller
  plug PlaylistLogWeb.Plugs.SpotifyAuth

  alias PlaylistLog.Playlists
  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track

  def list_playlists(conn, _params) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, logs} <- Playlists.list_playlists(spotify_user, spotify_access_token) do
      render(conn, "index.html", logs: Enum.sort(logs, &Log.alphabetically/2))
    else
      {:error, error} ->
        error_message = get_in(error, ["error", "message"])

        conn
        |> put_flash(:error, "Error when listing playlists: #{error_message}")
        |> redirect(to: "/")
    end
  end

  def index(conn, _params) do
    spotify_user = get_session(conn, :spotify_user)
    # spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, logs} <- Playlists.list_logs(spotify_user) do
      render(conn, "index.html", logs: Enum.sort(logs, &Log.alphabetically/2))
    else
      {:error, error} ->
        error_message = get_in(error, ["error", "message"])

        conn
        |> put_flash(:error, "Error when listing logs: #{error_message}")
        |> redirect(to: "/")
    end
  end

  def show(conn, %{"id" => id} = params) do
    show_events = Map.get(params, "show_events", "all")
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, id, spotify_access_token),
         ordered_tracks <- Enum.sort(log.tracks, &latest_first_order/2) do
      render(conn, "show.html",
        log: log,
        ordered_tracks: ordered_tracks,
        show_events: show_events
      )
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, "Unable to show playlist: #{inspect(reason)}")
        |> redirect(to: Routes.log_path(conn, :index))
    end
  end

  defp latest_first_order(%Track{} = t1, %Track{} = t2) do
    latest_first_order(t1.added_at, t2.added_at)
  end

  defp latest_first_order(%DateTime{} = d1, %DateTime{} = d2) do
    case DateTime.compare(d1, d2) do
      :lt -> false
      :gt -> true
      _ -> true
    end
  end

  def delete_track(conn, %{
        "log_id" => log_id,
        "snapshot_id" => snapshot_id,
        "track_uri" => track_uri
      }) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, log_id, spotify_access_token),
         {:ok, tracks} <-
           Playlists.delete_tracks(
             spotify_user,
             log.id,
             snapshot_id,
             [track_uri],
             spotify_access_token
           ),
         {:ok, track} <- Map.fetch(tracks, track_uri) do
      conn
      |> put_flash(:info, "#{track.artist} - #{track.name} removed successfully")
      |> redirect(to: Routes.log_path(conn, :show, log.id))
    end
  end

  def add_track(conn, %{"log_id" => log_id, "track" => %{"uri" => track_uri}}) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, log_id, spotify_access_token),
         {:ok, track} <- Playlists.add_track(log, track_uri, spotify_access_token) do
      conn
      |> put_flash(:info, "#{track.artist} - #{track.name} added successfully")
      |> redirect(to: Routes.log_path(conn, :show, log.id))
    end
  end
end
