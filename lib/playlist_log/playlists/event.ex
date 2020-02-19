defmodule PlaylistLog.Playlists.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlaylistLog.Playlists.Track

  @track_added "TRACK_ADDED"

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "events" do
    field(:timestamp, :utc_datetime)
    field(:type, :string)
    field(:user, :string)

    has_one(:track, Track)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:timstamp, :type, :user])
    |> validate_required([:timestamp, :type, :user])
  end

  def from_track(%Track{} = track) do
    %__MODULE__{
      track: track,
      user: track.added_by,
      timestamp: track.added_at,
      type: @track_added
    }
  end
end
