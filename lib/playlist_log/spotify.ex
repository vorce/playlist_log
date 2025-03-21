defmodule PlaylistLog.Spotify do
  @moduledoc """
  Spotify details
  """
  @behaviour PlaylistLog.MusicClient
  require Logger

  # https://developer.spotify.com/documentation/general/guides/scopes/

  @base_url "https://api.spotify.com/v1"
  @ok_status [200, 201]

  @doc """
  Get all user's playlists. Note: This will page through spotify's API to get ALL lists.

  - Official docs: https://developer.spotify.com/documentation/web-api/reference/playlists/get-a-list-of-current-users-playlists/
  """
  @impl PlaylistLog.MusicClient
  def get_playlists(access_token) do
    url = @base_url <> "/me/playlists?limit=50"
    get_next_page(url, access_token, [])
  end

  defp get_next_page(nil, _access_token, acc) do
    Logger.info("Done fetching #{length(acc)} pages of playlists")
    {:ok, List.flatten(acc)}
  end

  defp get_next_page(url, access_token, acc) do
    headers = [Authorization: "Bearer #{access_token}"]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, response} <- Jason.decode(body),
         {:ok, playlists} <- Map.fetch(response, "items") do
      get_next_page(response["next"], access_token, [playlists | acc])
    else
      other ->
        handle_unexpected_response(url, other)
    end
  end

  @doc """
  Get user info
  """
  def get_me(access_token) do
    headers = [Authorization: "Bearer #{access_token}"]
    url = @base_url <> "/me"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, response} <- Jason.decode(body) do
      {:ok, response}
    else
      other ->
        handle_unexpected_response(url, other)
    end
  end

  @doc """
  Get track details for a playlist.

  - Official docs: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlists-tracks/
  """
  @impl PlaylistLog.MusicClient
  def get_playlist_tracks(access_token, id) do
    headers = [Authorization: "Bearer #{access_token}"]
    url = @base_url <> "/playlists/#{id}/tracks"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, response} <- Jason.decode(body),
         {:ok, tracks} <- Map.fetch(response, "items") do
      {:ok, tracks}
    else
      other ->
        handle_unexpected_response(url, other)
    end
  end

  @doc """
  Delete tracks from a playlist.

  - Official docs: https://developer.spotify.com/documentation/web-api/reference/playlists/remove-tracks-playlist/
  """
  @impl PlaylistLog.MusicClient
  def delete_tracks_from_playlist(access_token, playlist_id, _snapshot_id, track_uris) do
    headers = [Authorization: "Bearer #{access_token}", "Content-type": "application/json"]
    url = @base_url <> "/playlists/#{playlist_id}/tracks"

    # Remove snapshot_id due to comments on:
    # https://community.spotify.com/t5/Spotify-for-Developers/Getting-502-response-on-DELETE-for-playlist-lt-playlistid-tracks/m-p/6736837
    # I've been getting 502 errors when deleting tracks.
    payload = %{
      tracks: Enum.map(track_uris, fn uri -> %{uri: uri} end)
      # snapshot_id: snapshot_id
    }

    with {:ok, request_body} <- Jason.encode(payload),
         {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} <-
           HTTPoison.request(:delete, url, request_body, headers),
         {:ok, response} <- Jason.decode(response_body) do
      {:ok, response["snapshot_id"]}
    else
      other ->
        handle_unexpected_response(url, other)
    end
  end

  @doc """
  Add tracks to a playlist

  - Official docs: https://developer.spotify.com/documentation/web-api/reference/add-tracks-to-playlist
  These docs changed at some point after the initial implementation.
  """
  @impl PlaylistLog.MusicClient
  def add_tracks_to_playlist(access_token, playlist_id, track_uris) do
    headers = [Authorization: "Bearer #{access_token}", "Content-type": "application/json"]
    url = @base_url <> "/playlists/#{playlist_id}/tracks"

    payload = %{
      uris: track_uris
    }

    with {:ok, request_body} <- Jason.encode(payload),
         {:ok, %HTTPoison.Response{status_code: status, body: response_body}}
         when status in @ok_status <-
           HTTPoison.post(url, request_body, headers),
         {:ok, response} <- Jason.decode(response_body) do
      {:ok, response["snapshot_id"]}
    else
      other ->
        handle_unexpected_response(url, other)
    end
  end

  @impl PlaylistLog.MusicClient
  def get_track("spotify:track:" <> track_id, access_token) do
    get_track(track_id, access_token)
  end

  @impl PlaylistLog.MusicClient
  def get_track(track_id, access_token) do
    headers = [Authorization: "Bearer #{access_token}"]
    url = @base_url <> "/tracks/#{track_id}"

    ConCache.fetch_or_store(:track_cache, track_id, fn ->
      with {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} <-
             HTTPoison.get(url, headers),
           {:ok, response} <- Jason.decode(response_body) do
        {:ok, response}
      else
        other ->
          handle_unexpected_response(url, other)
      end
    end)
  end

  @doc """
  Checks if a link is a valid spotify resource (uri or http link)
  """
  @impl PlaylistLog.MusicClient
  def validate_track_link(maybe_link) do
    case validate_uri(maybe_link) do
      {:error, _} -> validate_link(maybe_link)
      {:ok, {:track, uri}} -> {:ok, uri}
      _ -> {:error, :invalid_track_link}
    end
  end

  @doc """
  Checks if a string is a valid spotify uri.

  Example of valid uris:

    spotify:album:27ftYHLeunzcSzb33Wk1hf
    spotify:artist:3mvkWMe6swnknwscwvGCHO
    spotify:track:7lEptt4wbM0yJTvSG5EBof
  """
  def validate_uri(maybe_uri) do
    case String.split(maybe_uri, ":", parts: 3) do
      ["spotify", "track", _id] -> {:ok, {:track, maybe_uri}}
      ["spotify", "album", _id] -> {:ok, {:album, maybe_uri}}
      ["spotify", "artist", _id] -> {:ok, {:artist, maybe_uri}}
      _ -> {:error, :invalid_format}
    end
  end

  @doc """
  Validates a spotify link like https://open.spotify.com/track/2azLsNFfIPtxNU4QmJzPow?si=85f957ef77854352
  and turns it into a uri
  """
  def validate_link(maybe_link) do
    with {:ok, {type, maybe_id}} <- parse_maybe_link(maybe_link),
         {:ok, id} <- parse_link_id(maybe_id) do
      {:ok, "spotify:#{type}:#{id}"}
    end
  end

  defp parse_maybe_link(maybe_link) do
    case String.split(maybe_link, "/", parts: 5) do
      ["https:", "", "open.spotify.com", "track", id] ->
        {:ok, {"track", id}}

      ["https:", "", "open.spotify.com", "album", id] ->
        {:ok, {"album", id}}

      _ ->
        {:error, :invalid_link_format}
    end
  end

  defp parse_link_id(link_id) do
    case String.split(link_id, "?si=", parts: 2) do
      [id, _] -> {:ok, id}
      [id] -> {:ok, id}
      _ -> {:error, :invalid_link_id_format}
    end
  end

  defp handle_unexpected_response(url, {:ok, %HTTPoison.Response{status_code: 429, body: body}}) do
    Logger.info("Hit spotify rate-limit (429) for #{url}")
    {:error, {__MODULE__, Jason.decode!(body)}}
  end

  defp handle_unexpected_response(
         url,
         {:ok, %HTTPoison.Response{status_code: 400..499, body: body} = resp}
       ) do
    Logger.info("Client error from spotify #{url}: #{inspect(resp)}")
    {:error, {__MODULE__, Jason.decode!(body)}}
  end

  defp handle_unexpected_response(url, {:ok, %HTTPoison.Response{} = resp}) do
    Logger.error("Unexpected response from spotify #{url}: #{inspect(resp)}")
    {:error, {__MODULE__, resp}}
  end

  defp handle_unexpected_response(url, response) do
    Logger.error("Unexpected response from spotify #{url}: #{inspect(response)}")
    {:error, {__MODULE__, response}}
  end
end
