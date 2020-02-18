defmodule PlaylistLogWeb.PageController do
  use PlaylistLogWeb, :controller
  plug PlaylistLogWeb.Plugs.SpotifyAuth

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
