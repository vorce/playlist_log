defmodule PlaylistLog.Spotify do
  @moduledoc """
  Spotify details
  """
  require Logger

  # https://developer.spotify.com/documentation/general/guides/scopes/

  @base_url "https://api.spotify.com/v1"

  @doc """
  https://developer.spotify.com/documentation/web-api/reference/playlists/get-a-list-of-current-users-playlists/
  TODO: Pagination (return more than the first X playlists?)
  """
  def get_playlists(access_token) do
    headers = [Authorization: "Bearer #{access_token}"]
    url = @base_url <> "/me/playlists"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, response} <- Jason.decode(body),
         {:ok, playlists} <- Map.fetch(response, "items") do
      {:ok, playlists}
    else
      {:ok, %HTTPoison.Response{status_code: 400..499, body: body}} ->
        {:error, Jason.decode!(body)}

      {_, unexpected} ->
        Logger.error("Unexpected response from #{url}: #{inspect(unexpected)}")
        {:error, unexpected}
    end
  end

  def get_me(access_token) do
    headers = [Authorization: "Bearer #{access_token}"]
    url = @base_url <> "/me"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, response} <- Jason.decode(body) do
      {:ok, response}
    else
      {_, unexpected} ->
        Logger.error("Unexpected response from #{url}: #{inspect(unexpected)}")
        {:error, unexpected}
    end
  end

  @doc """
  https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlists-tracks/
  """
  def get_playlist_tracks(access_token, id) do
    headers = [Authorization: "Bearer #{access_token}"]
    url = @base_url <> "/playlists/#{id}/tracks"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, response} <- Jason.decode(body),
         {:ok, tracks} <- Map.fetch(response, "items") do
      {:ok, tracks}
    else
      {:ok, %HTTPoison.Response{status_code: 400..499, body: body}} ->
        {:error, Jason.decode!(body)}

      {_, unexpected} ->
        Logger.error("Unexpected response from #{url}: #{inspect(unexpected)}")
        {:error, unexpected}
    end
  end
end
