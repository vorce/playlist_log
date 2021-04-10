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
  @impl PlaylistLog.MusicClient
  def get_playlists("fail") do
    {:error, {__MODULE__, %{}}}
  end

  def get_playlists(_access_token) do
    {:ok, Jason.decode!(@get_playlists_response)}
  end

  @get_playlist_tracks_response """
  [
    {
      "added_at": "2016-10-11T13:44:40Z",
      "added_by": {
        "external_urls": {
          "spotify": "http://open.spotify.com/user/spotify_espa%C3%B1a"
        },
        "href": "https://api.spotify.com/v1/users/spotify_espa%C3%B1a",
        "id": "spotify_españa",
        "type": "user",
        "uri": "spotify:user:spotify_espa%C3%B1a"
      },
      "is_local": false,
      "track": {
        "album": {
          "album_type": "single",
          "artists": [
            {
              "external_urls": {
                "spotify": "https://open.spotify.com/artist/21451j1KhjAiaYKflxBjr1"
              },
              "href": "https://api.spotify.com/v1/artists/21451j1KhjAiaYKflxBjr1",
              "id": "21451j1KhjAiaYKflxBjr1",
              "name": "Zion & Lennox",
              "type": "artist",
              "uri": "spotify:artist:21451j1KhjAiaYKflxBjr1"
            }
          ],
          "available_markets": [
            "AD",
            "AR",
            "AT",
            "AU"
          ],
          "external_urls": {
            "spotify": "https://open.spotify.com/album/5GjKG3Y8OvSVJO55dQTFyD"
          },
          "href": "https://api.spotify.com/v1/albums/5GjKG3Y8OvSVJO55dQTFyD",
          "id": "5GjKG3Y8OvSVJO55dQTFyD",
          "images": [
            {
              "height": 640,
              "url": "https://i.scdn.co/image/b16064142fcd2bd318b08aab0b93b46e87b1ebf5",
              "width": 640
            },
            {
              "height": 300,
              "url": "https://i.scdn.co/image/9f05124de35d807b78563ea2ca69550325081747",
              "width": 300
            },
            {
              "height": 64,
              "url": "https://i.scdn.co/image/863c805b580a29c184fc447327e28af5dac9490b",
              "width": 64
            }
          ],
          "name": "Otra Vez (feat. J Balvin)",
          "type": "album",
          "uri": "spotify:album:5GjKG3Y8OvSVJO55dQTFyD"
        },
        "artists": [
          {
            "external_urls": {
              "spotify": "https://open.spotify.com/artist/21451j1KhjAiaYKflxBjr1"
            },
            "href": "https://api.spotify.com/v1/artists/21451j1KhjAiaYKflxBjr1",
            "id": "21451j1KhjAiaYKflxBjr1",
            "name": "Zion & Lennox",
            "type": "artist",
            "uri": "spotify:artist:21451j1KhjAiaYKflxBjr1"
          },
          {
            "external_urls": {
              "spotify": "https://open.spotify.com/artist/1vyhD5VmyZ7KMfW5gqLgo5"
            },
            "href": "https://api.spotify.com/v1/artists/1vyhD5VmyZ7KMfW5gqLgo5",
            "id": "1vyhD5VmyZ7KMfW5gqLgo5",
            "name": "J Balvin",
            "type": "artist",
            "uri": "spotify:artist:1vyhD5VmyZ7KMfW5gqLgo5"
          }
        ],
        "available_markets": [
          "AD",
          "AR",
          "AT",
          "AU"
        ],
        "disc_number": 1,
        "duration_ms": 209453,
        "explicit": false,
        "external_ids": {
          "isrc": "USWL11600423"
        },
        "external_urls": {
          "spotify": "https://open.spotify.com/track/7pk3EpFtmsOdj8iUhjmeCM"
        },
        "href": "https://api.spotify.com/v1/tracks/7pk3EpFtmsOdj8iUhjmeCM",
        "id": "7pk3EpFtmsOdj8iUhjmeCM",
        "name": "Otra Vez (feat. J Balvin)",
        "popularity": 85,
        "preview_url": "https://p.scdn.co/mp3-preview/79c8c9edc4f1ced9dbc368f24374421ed0a33005",
        "track_number": 1,
        "type": "track",
        "uri": "spotify:track:7pk3EpFtmsOdj8iUhjmeCM"
      }
    },
    {
      "added_at": "2016-10-11T13:44:40Z",
      "added_by": {
        "external_urls": {
          "spotify": "http://open.spotify.com/user/spotify_espa%C3%B1a"
        },
        "href": "https://api.spotify.com/v1/users/spotify_espa%C3%B1a",
        "id": "spotify_españa",
        "type": "user",
        "uri": "spotify:user:spotify_espa%C3%B1a"
      },
      "is_local": false,
      "track": {
          "uri": "fake"
      }
    }
  ]
  """
  @impl PlaylistLog.MusicClient
  def get_playlist_tracks(_access_token, _id) do
    {:ok, Jason.decode!(@get_playlist_tracks_response)}
  end

  @impl PlaylistLog.MusicClient
  def delete_tracks_from_playlist(_access_token, _playlist_id, snapshot_id, _track_uris) do
    {:ok, String.reverse(snapshot_id)}
  end

  @impl PlaylistLog.MusicClient
  def add_tracks_to_playlist(_access_token, playlist_id, _track_uris) do
    {:ok, String.reverse(playlist_id)}
  end

  @impl PlaylistLog.MusicClient
  def validate_track_link(uri) do
    {:ok, uri}
  end

  @get_track_response """
  {
    "album": {
      "album_type": "single",
      "artists": [
        {
          "external_urls": {
              "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
          },
          "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
          "id": "6sFIWsNpZYqfjUpaCgueju",
          "name": "Carly Rae Jepsen",
          "type": "artist",
          "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
        }
      ],
      "available_markets": [
        "AD"
      ],
      "external_urls": {
        "spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"
      },
      "href": "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
      "id": "0tGPJ0bkWOUmH7MEOR77qc",
      "images": [
        {
          "height": 640,
          "url": "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee",
          "width": 640
        },
        {
          "height": 300,
          "url": "https://i.scdn.co/image/107819f5dc557d5d0a4b216781c6ec1b2f3c5ab2",
          "width": 300
        },
        {
          "height": 64,
          "url": "https://i.scdn.co/image/5a73a056d0af707b4119a883d87285feda543fbb",
          "width": 64
        }
      ],
      "name": "Cut To The Feeling",
      "release_date": "2017-05-26",
      "release_date_precision": "day",
      "type": "album",
      "uri": "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
    },
    "artists": [
      {
        "external_urls": {
            "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
        },
        "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
        "id": "6sFIWsNpZYqfjUpaCgueju",
        "name": "Carly Rae Jepsen",
        "type": "artist",
        "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
      }
    ],
    "available_markets": [
        "AD"
    ],
    "disc_number": 1,
    "duration_ms": 207959,
    "explicit": false,
    "external_ids": {
      "isrc": "USUM71703861"
    },
    "external_urls": {
      "spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"
    },
    "href": "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
    "id": "11dFghVXANMlKmJXsNCbNl",
    "is_local": false,
    "name": "Cut To The Feeling",
    "popularity": 63,
    "preview_url": "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
    "track_number": 1,
    "type": "track",
    "uri": "spotify:track:11dFghVXANMlKmJXsNCbNl"
  }
  """
  @impl PlaylistLog.MusicClient
  def get_track(_id, _access_token) do
    {:ok, Jason.decode!(@get_track_response)}
  end

  def user(), do: "wizzler"
end
