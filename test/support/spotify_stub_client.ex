defmodule PlaylistLog.Test.SpotifyStubClient do
  @moduledoc """
  Spotify client that returns stubbed data
  """
  @behaviour PlaylistLog.MusicClient

  @get_playlists_response """
  [
    {
        "collaborative": false,
        "external_urls": {
            "spotify": "http://open.spotify.com/user/wizzler/playlists/53Y8wT46QIMz5H4WQ8O22c"
        },
        "href": "https://api.spotify.com/v1/users/wizzler/playlists/53Y8wT46QIMz5H4WQ8O22c",
        "id": "53Y8wT46QIMz5H4WQ8O22c",
        "images": [],
        "name": "Wizzlers Big Playlist",
        "owner": {
            "external_urls": {
                "spotify": "http://open.spotify.com/user/wizzler"
            },
            "href": "https://api.spotify.com/v1/users/wizzler",
            "id": "wizzler",
            "type": "user",
            "uri": "spotify:user:wizzler"
        },
        "public": true,
        "snapshot_id": "bNLWdmhh+HDsbHzhckXeDC0uyKyg4FjPI/KEsKjAE526usnz2LxwgyBoMShVL+z+",
        "tracks": {
            "href": "https://api.spotify.com/v1/users/wizzler/playlists/53Y8wT46QIMz5H4WQ8O22c/tracks",
            "total": 30
        },
        "type": "playlist",
        "uri": "spotify:user:wizzler:playlist:53Y8wT46QIMz5H4WQ8O22c"
    },
    {
        "collaborative": false,
        "external_urls": {
            "spotify": "http://open.spotify.com/user/wizzlersmate/playlists/1AVZz0mBuGbCEoNRQdYQju"
        },
        "href": "https://api.spotify.com/v1/users/wizzlersmate/playlists/1AVZz0mBuGbCEoNRQdYQju",
        "id": "1AVZz0mBuGbCEoNRQdYQju",
        "images": [],
        "name": "Another Playlist",
        "owner": {
            "external_urls": {
                "spotify": "http://open.spotify.com/user/wizzlersmate"
            },
            "href": "https://api.spotify.com/v1/users/wizzlersmate",
            "id": "wizzlersmate",
            "type": "user",
            "uri": "spotify:user:wizzlersmate"
        },
        "public": true,
        "snapshot_id": "Y0qg/IT5T02DKpw4uQKc/9RUrqQJ07hbTKyEeDRPOo9LU0g0icBrIXwVkHfQZ/aD",
        "tracks": {
            "href": "https://api.spotify.com/v1/users/wizzlersmate/playlists/1AVZz0mBuGbCEoNRQdYQju/tracks",
            "total": 58
        },
        "type": "playlist",
        "uri": "spotify:user:wizzlersmate:playlist:1AVZz0mBuGbCEoNRQdYQju"
    }
  ]
  """
  def get_playlists("fail") do
    {:error, {__MODULE__, %{}}}
  end

  def get_playlists(_access_token) do
    {:ok, Jason.decode!(@get_playlists_response)}
  end

  def user(), do: "wizzler"
end
