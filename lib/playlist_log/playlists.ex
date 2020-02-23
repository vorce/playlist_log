defmodule PlaylistLog.Playlists do
  @moduledoc """
  The Playlists context.
  """

  import Ecto.Query, warn: false
  alias PlaylistLog.Repo

  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track
  alias PlaylistLog.Spotify

  # TODO: This is probably the first you have to do when coming to /logs
  # and after adding a new playlist to spotify
  def list_playlists(user, access_token) do
    with {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, playlists} <- Spotify.get_playlists(access_token),
         logs <- Enum.map(playlists, &Log.new(&1, fetched_by: user_id)),
         :ok <- Repo.insert(Log, user_id, logs) do
      {:ok, logs}
    end
  end

  @doc """
  Returns the list of logs.

  ## Examples

      iex> list_logs()
      [%Log{}, ...]

  """
  def list_logs(user) do
    with {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, logs} <- Repo.all(Log, user_id) do
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
  def get_log(user, log_id, access_token) do
    with {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, log} <- Repo.get(Log, {user_id, log_id}),
         {:ok, raw_tracks} <- Spotify.get_playlist_tracks(access_token, log_id),
         tracks <- Enum.map(raw_tracks, &Track.new/1),
         combined_events <- combine_events(log_id, tracks, log.events),
         :ok <-
           Repo.update(
             Log.changeset(%Log{log | events: combined_events}, %{
               tracks: tracks,
               event_count: length(combined_events)
             })
           ) do
      {:ok,
       %Log{
         log
         | tracks: tracks,
           track_count: length(tracks),
           events: combined_events,
           event_count: length(combined_events)
       }}
    end
  end

  defp combine_events(log_id, tracks, events) do
    track_added_events = Enum.map(tracks, &Event.from_track(log_id, &1))

    track_added_events
    |> Enum.concat(events)
    |> Enum.uniq_by(fn event ->
      {event.timestamp, event.user, event.type, event.track_uri}
    end)
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

  def delete_tracks(user, log_id, snapshot_id, track_uris, access_token) do
    with {:ok, new_snapshot_id} <-
           Spotify.delete_tracks_from_playlist(access_token, log_id, snapshot_id, track_uris),
         {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, log} <- Repo.get(Log, {user_id, log_id}),
         changeset <- Log.changeset(log, %{snapshot_id: new_snapshot_id}),
         :ok <- Repo.update(changeset) do
      Enum.each(track_uris, fn track_uri ->
        track = Enum.find(log.tracks, fn track -> track.uri == track_uri end)
        track_artist = Track.artist_string(track)

        create_event(log_id, %{
          timestamp: DateTime.utc_now(),
          type: "TRACK_REMOVED",
          user: user_id,
          track_uri: track_uri,
          track_name: track.name,
          track_artist: track_artist,
          log_id: log_id
        })
      end)
    end
  end

  def add_tracks(user, %Log{} = log, track_uris, access_token) do
    with {:ok, new_snapshot_id} <-
           Spotify.add_tracks_to_playlist(access_token, log.id, track_uris),
         {:ok, user_id} <- Map.fetch(user, "id"),
         changeset <- Log.changeset(log, %{snapshot_id: new_snapshot_id}),
         :ok <- Repo.update(changeset) do
      result =
        Enum.reduce(track_uris, %{}, fn track_uri, acc ->
          with {:ok, raw_track} <- Spotify.get_track(track_uri, access_token) do
            simplified_track = %{
              artist: Track.artist_string(raw_track),
              name: raw_track["name"],
              uri: track_uri
            }

            create_event(log.id, %{
              timestamp: DateTime.utc_now(),
              type: "TRACK_ADDED",
              user: user_id,
              track_uri: track_uri,
              track_name: simplified_track.name,
              track_artist: simplified_track.artist,
              log_id: log.id
            })

            Map.put(acc, track_uri, simplified_track)
          end
        end)

      {:ok, result}
    end
  end

  def create_event(log_id, attrs \\ %{}) do
    changeset = Event.changeset(%Event{}, attrs)
    Repo.insert(Event, log_id, changeset)
  end
end
