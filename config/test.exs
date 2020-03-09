import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :playlist_log, PlaylistLogWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :playlist_log, PlaylistLog.Repo, data_dir: "priv/cubdb_test"

config :playlist_log, PlaylistLog.Playlists, spotify_client: PlaylistLog.Test.SpotifyStubClient
