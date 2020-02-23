defmodule PlaylistLogWeb.LogController do
  use PlaylistLogWeb, :controller
  plug PlaylistLogWeb.Plugs.SpotifyAuth

  alias PlaylistLog.Playlists
  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track

  def index(conn, _params) do
    spotify_user = get_session(conn, :spotify_user)
    # spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, logs} <- Playlists.list_logs(spotify_user) do
      render(conn, "index.html", logs: Enum.sort(logs, fn l1, l2 -> l1.name <= l2.name end))
    else
      {:error, error} ->
        error_message = get_in(error, ["error", "message"])

        conn
        |> put_flash(:error, "Error when listing playlists: #{error_message}")
        |> redirect(to: "/")
    end
  end

  def new(conn, _params) do
    changeset = Playlists.change_log(%Log{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"log" => log_params}) do
    case Playlists.create_log(log_params) do
      {:ok, log} ->
        conn
        |> put_flash(:info, "Log created successfully.")
        |> redirect(to: Routes.log_path(conn, :show, log))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, id, spotify_access_token),
         ordered_tracks <- Enum.sort(log.tracks, &latest_first_order/2),
         ordered_events <- Enum.sort(log.events, &latest_first_order/2) do
      render(conn, "show.html",
        log: log,
        ordered_tracks: ordered_tracks,
        ordered_events: ordered_events
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

  defp latest_first_order(%Event{} = e1, %Event{} = e2) do
    latest_first_order(e1.timestamp, e2.timestamp)
  end

  defp latest_first_order(%DateTime{} = d1, %DateTime{} = d2) do
    case DateTime.compare(d1, d2) do
      :lt -> false
      :gt -> true
      _ -> true
    end
  end

  def edit(conn, %{"id" => id}) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, id, spotify_access_token) do
      changeset = Playlists.change_log(log)
      render(conn, "edit.html", log: log, changeset: changeset)
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, "Unable to update playlist: #{inspect(reason)}")
        |> redirect(to: Routes.log_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "log" => log_params}) do
    log = Playlists.get_log!(id)

    case Playlists.update_log(log, log_params) do
      {:ok, log} ->
        conn
        |> put_flash(:info, "Log updated successfully.")
        |> redirect(to: Routes.log_path(conn, :show, log))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", log: log, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    log = Playlists.get_log!(id)
    {:ok, _log} = Playlists.delete_log(log)

    conn
    |> put_flash(:info, "Log deleted successfully.")
    |> redirect(to: Routes.log_path(conn, :index))
  end

  def delete_track(conn, %{
        "log_id" => log_id,
        "snapshot_id" => snapshot_id,
        "track_uri" => track_uri
      }) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, log_id, spotify_access_token),
         :ok <-
           Playlists.delete_tracks(
             spotify_user,
             log.id,
             snapshot_id,
             [track_uri],
             spotify_access_token
           ) do
      conn
      |> put_flash(:info, "Playlist track deleted successfully.")
      |> redirect(to: Routes.log_path(conn, :show, log.id))
    end
  end

  def add_track(conn, %{"log_id" => log_id, "track" => %{"uri" => track_uri}}) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, log} <- Playlists.get_log(spotify_user, log_id, spotify_access_token),
         {:ok, tracks} <-
           Playlists.add_tracks(spotify_user, log, [track_uri], spotify_access_token),
         {:ok, track} <- Map.fetch(tracks, track_uri) do
      conn
      |> put_flash(:info, "Playlist track added successfully.")
      |> redirect(to: Routes.log_path(conn, :show, log.id))
    end
  end
end
