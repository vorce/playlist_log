# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :playlist_log, PlaylistLogWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
config :playlist_log, PlaylistLogWeb.Endpoint, server: true

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

config :playlist_log, PlaylistLogWeb.DockerhubController,
  key: System.get_env("DOCKERHUB_WEBHOOK_KEY")
