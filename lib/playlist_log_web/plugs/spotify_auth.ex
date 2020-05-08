defmodule PlaylistLogWeb.Plugs.SpotifyAuth do
  @moduledoc """
  Spotify auth
  """
  def init(default), do: default

  def call(conn, _default) do
    authenticated? = Spotify.Authentication.authenticated?(conn)

    if authenticated? do
      case refresh(conn) do
        {:ok, conn} ->
          conn
      end
    else
      conn
      |> Phoenix.Controller.redirect(external: Spotify.Authorization.url())
      |> Plug.Conn.halt()
    end
  end

  @doc """
  I am sort of re-implementing Spotify.Authentication.refresh here
  because I want to lower the max_age of the spotify cookies.
  """
  def refresh(%Plug.Conn{assigns: %{spotify: :no_refresh}} = conn), do: {:ok, conn}

  def refresh(%Plug.Conn{assigns: %{}} = conn) do
    with {:ok, auth} <- conn |> Spotify.Credentials.new() |> refresh do
      {:ok, set_cookies(conn, auth)}
    end
  end

  def refresh(%Spotify.Credentials{refresh_token: nil}), do: :unauthorized
  def refresh(auth), do: auth |> body_params |> AuthenticationClient.post()

  @doc false
  def body_params(%Spotify.Credentials{refresh_token: token}) do
    "grant_type=refresh_token&refresh_token=#{token}"
  end

  def set_cookies(conn, credentials) do
    opts = [max_age: 3_500]

    conn
    |> set_cookie("spotify_refresh_token", credentials.refresh_token, opts)
    |> set_cookie("spotify_access_token", credentials.access_token, opts)
  end

  def set_cookie(conn, _key, nil, _opts), do: conn

  def set_cookie(conn, key, value, opts) do
    Plug.Conn.put_resp_cookie(conn, key, value, opts)
  end
end
