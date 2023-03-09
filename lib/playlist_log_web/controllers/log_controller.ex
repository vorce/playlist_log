defmodule PlaylistLogWeb.LogController do
  use PlaylistLogWeb, :controller
  plug(PlaylistLogWeb.Plugs.SpotifyAuth)

  require Logger

  alias PlaylistLog.Playlists
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track

  def list_playlists(conn, _params) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    case Playlists.list_playlists(spotify_user, spotify_access_token) do
      {:ok, logs} ->
        render(conn, "index.html", logs: Enum.sort(logs, &Log.alphabetically/2))

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

    case Playlists.list_logs(spotify_user) do
      {:ok, logs} ->
        render(conn, "index.html", logs: Enum.sort(logs, &Log.alphabetically/2))

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
    one_year_ago = Date.add(Date.utc_today(), -365)
    one_year_and_week_ago = Date.add(one_year_ago, -7)

    with {:ok, log} <- Playlists.get_log(spotify_user, id, spotify_access_token),
         ordered_tracks <- Enum.sort(log.tracks, &latest_first_order/2),
         {:ok, old_events} <- get_old_events(log.id, 3) do
      render(conn, "show.html",
        log: log,
        ordered_tracks: ordered_tracks,
        show_events: show_events,
        subtitle: log.name,
        old_events: old_events
      )
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, "Unable to show playlist: #{inspect(reason)}")
        |> redirect(to: Routes.log_path(conn, :index))
    end
  end

  defp get_old_events(log_id, limit) do
    one_year_ago = Date.add(Date.utc_today(), -365)
    one_year_and_week_ago = Date.add(one_year_ago, -7)
    date_range = Date.range(one_year_and_week_ago, one_year_ago)
    filter_fn = fn e -> e.type == "TRACK_REMOVED" end

    with {:ok, events} <- Playlists.events_between(log_id, date_range, filter_fn: filter_fn) do
      limited_events =
        events
        |> Enum.sort_by(fn e -> e.timestamp end, {:desc, DateTime})
        |> Enum.take(limit)

      {:ok, limited_events}
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

  def add_track(conn, %{"log_id" => log_id, "track" => %{"uri" => track_uri}} = params) do
    remove_oldest? = get_in(params, ["track", "remove_oldest"])
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, log_id, spotify_access_token),
         {:ok, track} <- Playlists.add_track(log, track_uri, spotify_access_token),
         {:remove, {:ok, _}} <-
           maybe_remove_oldest(
             remove_oldest?,
             spotify_user,
             log,
             track.snapshot_id,
             spotify_access_token
           ) do
      conn
      |> put_flash(:info, "#{track.artist} - #{track.name} added successfully")
      |> redirect(to: Routes.log_path(conn, :show, log.id))
    else
      {:remove, unexpected} ->
        Logger.error("Failed to remove the oldest added track, reason: #{inspect(unexpected)}")

        conn
        |> put_flash(:error, "Unable to remove the oldest track")
        |> redirect(to: Routes.log_path(conn, :show, log_id))

      {:ok, :album} ->
        conn
        |> put_flash(:error, "Can't add an album to the list")
        |> redirect(to: Routes.log_path(conn, :show, log_id))

      {:ok, :artist} ->
        conn
        |> put_flash(:error, "Can't add an artist to the list")
        |> redirect(to: Routes.log_path(conn, :show, log_id))

      {:error, :invalid_format} ->
        conn
        |> put_flash(:error, "Invalid spotify uri")
        |> redirect(to: Routes.log_path(conn, :show, log_id))
    end
  end

  defp maybe_remove_oldest("false", _, _, _, _) do
    {:remove, {:ok, %{}}}
  end

  defp maybe_remove_oldest("true", spotify_user, log, snapshot_id, access_token) do
    {:remove, Playlists.remove_oldest_track(spotify_user, log, snapshot_id, access_token)}
  end
end
