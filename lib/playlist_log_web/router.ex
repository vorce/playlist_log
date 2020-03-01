defmodule PlaylistLogWeb.Router do
  use PlaylistLogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlaylistLogWeb do
    pipe_through :browser

    get "/", LogController, :index
    resources "/logs", LogController
    delete "/logs/:log_id/snapshots/:snapshot_id/tracks/:track_uri", LogController, :delete_track
    post "/logs/:log_id/tracks", LogController, :add_track
    get "/playlists", LogController, :list_playlists
    get "/spotify_callback", SpotifyCallbackController, :authenticate
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlaylistLogWeb do
  #   pipe_through :api
  # end
end
