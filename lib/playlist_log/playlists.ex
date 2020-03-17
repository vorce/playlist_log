defmodule PlaylistLog.Playlists do
  @moduledoc """
  The Playlists context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias PlaylistLog.Repo

  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Log
  alias PlaylistLog.Playlists.Track

  # Spotify client from config
  defp spotify(), do: Application.get_env(:playlist_log, PlaylistLog.Playlists)[:spotify_client]

  # TODO: This is probably the first you have to do when coming to /logs
  # and after adding a new playlist to spotify or changing its properties (like name, description)
  def list_playlists(user, access_token) do
    with {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, playlists} <- spotify().get_playlists(access_token),
         owned_playlists <-
           Enum.filter(playlists, fn playlist -> get_in(playlist, ["owner", "id"]) == user_id end),
         logs <- Enum.map(owned_playlists, &Log.new(&1, fetched_by: user_id)),
         :ok <- Repo.update(Log, user_id, logs, &merge_spotify_data/2) do
      {:ok, Enum.sort(logs, &alphabetically/2)}
    end
  end

  defp merge_spotify_data(%Log{} = existing, %Log{} = new) do
    %Log{
      existing
      | track_count: new.track_count,
        description: new.description,
        name: new.name,
        snapshot_id: new.snapshot_id,
        collaborative: new.collaborative
    }
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
      {:ok, Enum.sort(logs, &alphabetically/2)}
    end
  end

  defp alphabetically(log1, log2) do
    log1.name <= log2.name
  end

  @doc """
  Gets a single log.

  ## Examples

      iex> get_log("octavorce", 1234)
      {:ok, %Log{}}

      iex> get_log("octavorce", -1)
      {:error, {:no_such_resource, {"octavorce", -1}}}

  """
  def get_log(user, log_id, access_token) do
    with {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, log} <- Repo.get(Log, {user_id, log_id}),
         {:ok, raw_tracks} <- spotify().get_playlist_tracks(access_token, log_id),
         tracks <- Enum.map(raw_tracks, &Track.new/1),
         {unique_events, missing_events} <- unique_events(log_id, tracks, log.events),
         :ok <-
           Repo.update(
             Log.changeset(%Log{log | events: unique_events}, %{
               tracks: tracks,
               event_count: length(unique_events)
             })
           ) do
      Enum.each(missing_events, &create_event(log_id, &1))

      {:ok,
       %Log{
         log
         | tracks: tracks,
           track_count: length(tracks),
           events: unique_events,
           event_count: length(unique_events)
       }}
    end
  end

  defp unique_events(log_id, tracks, events) do
    track_added_events = Enum.map(tracks, &Event.from_track(log_id, &1))
    missing_events = missing_events(events, track_added_events)

    unique_events =
      track_added_events
      |> Enum.concat(events)
      |> Enum.uniq_by(fn event ->
        {DateTime.to_iso8601(event.timestamp), event.user, event.log_id, event.type,
         event.track_uri}
      end)

    details = [
      existing_events: length(events),
      track_added_events: length(track_added_events),
      missing_events: length(missing_events),
      unique_events: length(unique_events)
    ]

    Logger.debug("Event details: #{inspect(details)}")

    {unique_events, missing_events}
  end

  defp missing_events(events, track_added_events) do
    events_by_date = Enum.group_by(events, fn e -> DateTime.to_date(e.timestamp) end)

    Enum.map(track_added_events, fn track_added ->
      event_date = DateTime.to_date(track_added.timestamp)

      case Map.get(events_by_date, event_date) do
        nil ->
          track_added

        existing when is_list(existing) ->
          missing_event(existing, track_added)
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp missing_event(existing, event) do
    case Enum.find(existing, fn e ->
           {DateTime.to_iso8601(e.timestamp), e.type, e.log_id, e.track_uri} ==
             {DateTime.to_iso8601(event.timestamp), event.type, event.log_id, event.track_uri}
         end) do
      nil ->
        event

      _ ->
        nil
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
  def create_log(_attrs \\ %{}) do
    # %Log{}
    # |> Log.changeset(attrs)
    # |> Repo.insert()
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
  def delete_log(%Log{} = _log) do
    # Repo.delete(log)
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

  @doc """
  Delete a track from a spotify playlist (and its log)
  """
  def delete_tracks(user, log_id, snapshot_id, track_uris, access_token) do
    with {:ok, new_snapshot_id} <-
           spotify().delete_tracks_from_playlist(access_token, log_id, snapshot_id, track_uris),
         {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, log} <- Repo.get(Log, {user_id, log_id}),
         changeset <-
           Log.changeset(log, %{
             snapshot_id: new_snapshot_id,
             event_count: log.event_count + length(track_uris),
             track_count: log.track_count - length(track_uris)
           }),
         :ok <- Repo.update(changeset) do
      result =
        Enum.reduce(track_uris, %{}, fn track_uri, acc ->
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

          simplified_track = %{
            artist: track_artist,
            name: track.name,
            uri: track_uri
          }

          Map.put(acc, track_uri, simplified_track)
        end)

      {:ok, result}
    end
  end

  def add_tracks(%Log{} = log, track_uris, access_token) do
    with {:ok, new_snapshot_id} <-
           spotify().add_tracks_to_playlist(access_token, log.id, track_uris),
         changeset <-
           Log.changeset(log, %{
             snapshot_id: new_snapshot_id,
             event_count: log.event_count + length(track_uris),
             track_count: log.track_count + length(track_uris)
           }),
         :ok <- Repo.update(changeset) do
      result =
        Enum.reduce(track_uris, %{}, fn track_uri, acc ->
          with {:ok, raw_track} <- spotify().get_track(track_uri, access_token) do
            simplified_track = %{
              artist: Track.artist_string(raw_track),
              name: raw_track["name"],
              uri: track_uri
            }

            Map.put(acc, track_uri, simplified_track)
          end
        end)

      {:ok, result}
    end
  end

  def create_event(log_id, attrs)

  def create_event(log_id, %Event{} = event) do
    Repo.insert(Event, log_id, event)
  end

  def create_event(log_id, %{} = attrs) do
    changeset = Event.changeset(%Event{}, attrs)
    Repo.insert(Event, log_id, changeset)
  end
end
