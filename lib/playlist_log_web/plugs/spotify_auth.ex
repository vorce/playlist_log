defmodule PlaylistLogWeb.Plugs.SpotifyAuth do
  @moduledoc """
  Spotify auth
  """
  def init(default), do: default

  def call(conn, _default) do
    authenticated? = Spotify.Authentication.authenticated?(conn)

    unless authenticated? do
      Phoenix.Controller.redirect(conn, external: Spotify.Authorization.url())
    else
      with {:ok, conn} <- Spotify.Authentication.refresh(conn) do
        conn
      end
    end
  end
end
