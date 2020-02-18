defmodule PlaylistLogWeb.LogController do
  use PlaylistLogWeb, :controller
  plug PlaylistLogWeb.Plugs.SpotifyAuth

  alias PlaylistLog.Playlists
  alias PlaylistLog.Playlists.Log

  def index(conn, _params) do
    spotify_user = get_session(conn, :spotify_user)
    spotify_access_token = conn.cookies["spotify_access_token"]

    with {:ok, logs} <- Playlists.list_logs(spotify_user, spotify_access_token) do
      render(conn, "index.html", logs: logs)
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

    with {:ok, log} <- Playlists.get_log(spotify_user, id, spotify_access_token) do
      render(conn, "show.html", log: log)
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, "Unable to show playlist: #{inspect(reason)}")
        |> redirect(to: Routes.log_path(conn, :index))
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
end
