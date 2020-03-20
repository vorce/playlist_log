defmodule PlaylistLog.MusicClient do
  @moduledoc """
  Client behaviour for a music platform
  """

  @callback get_playlists(access_token :: String.t()) ::
              {:ok, list(Map.t())} | {:error, {Module.t(), any}}

  @callback get_playlist_tracks(access_token :: String.t(), id :: String.t()) ::
              {:ok, list(Map.t())} | {:error, {Module.t(), any}}

  @callback get_track(track_id :: String.t(), access_token :: String.t()) ::
              {:ok, Map.t()} | {:error, {Module.t(), any}}

  @callback delete_tracks_from_playlist(
              access_token :: String.t(),
              playlist_id :: String.t(),
              snapshot_id :: String.t(),
              track_uris :: list(String.t())
            ) :: {:ok, String.t()} | {:error, {Module.t(), any}}

  @callback add_tracks_to_playlist(
              access_token :: String.t(),
              playlist_id :: String.t(),
              track_uris :: list(String.t())
            ) :: {:ok, String.t()} | {:error, {Module.t(), any}}
end
