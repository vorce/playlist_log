# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :playlist_log, PlaylistLogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pzeDB0c+6lv7SPX+nT1orYlOSTMHKnjgaPRSf7TQ8Rs3pMtVCKUmi1o+LMLl/exB",
  render_errors: [view: PlaylistLogWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: PlaylistLog.PubSub,
  live_view: [
    signing_salt: "JNvyNg8AHcWKr4uvWuCea8IrVH0gmQhS"
  ]

# Path.join(:code.priv_dir(:playlist_log), "cubdb")
config :playlist_log, PlaylistLog.Repo,
  data_dir: "priv/cubdb",
  auto_compact: true

config :playlist_log, PlaylistLog.Playlists, spotify_client: PlaylistLog.Spotify

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spotify_ex,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  secret_key: System.get_env("SPOTIFY_CLIENT_SECRET"),
  callback_url:
    System.get_env("SPOTIFY_REDIRECT_URI") || "http://localhost:4000/spotify_callback",
  user_id: "unknown",
  scopes: [
    "playlist-modify-public",
    "playlist-modify-private",
    "playlist-read-private",
    "playlist-read-collaborative"
  ]

# Overridden in releases.exs
config :playlist_log, PlaylistLogWeb.DockerhubController, key: "testkey"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
