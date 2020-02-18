defmodule PlaylistLog.Playlists do
  @moduledoc """
  The Playlists context.
  """

  import Ecto.Query, warn: false
  alias PlaylistLog.Repo

  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track
  alias PlaylistLog.Spotify

  @doc """
  Returns the list of logs.

  ## Examples

      iex> list_logs()
      [%Log{}, ...]

  """
  def list_logs(user, access_token) do
    # TODO what about old ones in db, but no longer in spotify?
    with {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, playlists} <- Spotify.get_playlists(access_token),
         logs <- Enum.map(playlists, &Log.new(&1, user_id)),
         :ok <- Repo.insert(Log, user_id, logs) do
      {:ok, logs}
    end
  end

  @doc """
  Gets a single log.

  Raises `Ecto.NoResultsError` if the Log does not exist.

  ## Examples

      iex> get_log("octavorce", 1234)
      {:ok, %Log{}}

      iex> get_log("octavorce", -1)
      {:error, {:no_such_resource, {"octavorce", -1}}}

  """
  def get_log(user, id, access_token) do
    with {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, log} <- Repo.get(Log, {user_id, id}),
         {:ok, raw_tracks} <- Spotify.get_playlist_tracks(access_token, id),
         tracks <- Enum.map(raw_tracks, &Track.new/1) |> IO.inspect(label: "track structs") do
      # TODO: create Track schema, and convert response from spotify raw track maps to Tracks
      {:ok, %Log{log | tracks: tracks}}
    end
  end

  @doc """
  Creates a log.

  ## Examples

      iex> create_log(%{field: value})
      {:ok, %Log{}}

      iex> create_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_log(attrs \\ %{}) do
    %Log{}
    |> Log.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value})
      {:ok, %Log{}}

      iex> update_log(log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_log(%Log{} = log, attrs) do
    log
    |> Log.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a log.

  ## Examples

      iex> delete_log(log)
      {:ok, %Log{}}

      iex> delete_log(log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_log(%Log{} = log) do
    Repo.delete(log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log changes.

  ## Examples

      iex> change_log(log)
      %Ecto.Changeset{source: %Log{}}

  """
  def change_log(%Log{} = log) do
    Log.changeset(log, %{})
  end
end
