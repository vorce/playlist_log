defmodule PlaylistLogWeb.SpotifyCallbackController do
  use PlaylistLogWeb, :controller

  def authenticate(conn, params) do
    with {:ok, conn} <- Spotify.Authentication.authenticate(conn, params),
         spotify_access_token <- conn.cookies["spotify_access_token"],
         {:ok, user_info} <- PlaylistLog.Spotify.get_me(spotify_access_token) do
      conn
      |> put_session(:spotify_user, user_info)
      |> put_flash(:info, "Successfully authenticated with Spotify")
      |> redirect(to: Routes.log_path(conn, :index))
      |> IO.inspect(label: "conn after SpotifyCallbackController.authenticate")
    else
      {:error, reason, conn} ->
        conn
        |> put_flash(:error, "Unable to authenticate with Spotify: #{inspect(reason)}")
        |> redirect(to: "/")
    end
  end

  def logout(conn, params) do
    # TODO
  end
end
