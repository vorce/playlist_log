defmodule PlaylistLogWeb.Router do
  use PlaylistLogWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker, excluded_paths: [~r(/spotify_callback*)]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlaylistLogWeb do
    pipe_through :browser

    get "/", LogController, :index

    get "/logs", LogController, :index
    get "/logs/:id", LogController, :show
    delete "/logs/:log_id/snapshots/:snapshot_id/tracks/:track_uri", LogController, :delete_track
    post "/logs/:log_id/tracks", LogController, :add_track
    get "/playlists", LogController, :list_playlists
    get "/spotify_callback", SpotifyCallbackController, :authenticate
  end

  scope "/api", PlaylistLogWeb do
    pipe_through :api

    post "/dockerhub", DockerhubController, :webhook
  end
end
