defmodule PlaylistLogWeb.SpotifyCallbackController do
  use PlaylistLogWeb, :controller

  def authenticate(conn, params) do
    with {:ok, conn} <- Spotify.Authentication.authenticate(conn, params),
         spotify_access_token <- conn.cookies["spotify_access_token"],
         {:ok, user_info} <- PlaylistLog.Spotify.get_me(spotify_access_token) do
      conn
      |> put_session(:spotify_user, user_info)
      |> put_flash(:info, "Successfully authenticated with Spotify")
      |> redirect(to: last_path(conn))
    else
      {:error, reason, conn} ->
        conn
        |> put_flash(:error, "Unable to authenticate with Spotify: #{inspect(reason)}")
        |> redirect(to: "/")
    end
  end

  def logout(_conn, _params) do
    # TODO
  end

  defp last_path(conn) do
    NavigationHistory.last_path(conn, default: Routes.log_path(conn, :index))
  end
end
