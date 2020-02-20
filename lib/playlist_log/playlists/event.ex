defmodule PlaylistLog.Playlists.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlaylistLog.Playlists.Track

  @track_added "TRACK_ADDED"
  @track_removed "TRACK_REMOVED"

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "events" do
    field(:timestamp, :utc_datetime)
    field(:type, :string)
    field(:user, :string)
    field(:log_id, :string)
    field(:track_uri, :string)
    field(:track_name, :string)
    field(:track_artist, :string)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:log_id, :timestamp, :type, :user, :track_uri, :track_name, :track_artist])
    |> validate_required([
      :log_id,
      :timestamp,
      :type,
      :user,
      :track_uri,
      :track_name,
      :track_artist
    ])
  end

  def from_track(log_id, %Track{} = track) do
    %__MODULE__{
      track_uri: track.uri,
      user: track.added_by,
      timestamp: track.added_at,
      type: @track_added,
      track_name: track.name,
      track_artist: Track.artist_string(track),
      log_id: log_id
    }
  end
end
