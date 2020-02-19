defmodule PlaylistLog.Playlists.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "tracks" do
    field(:name, :string)
    field(:artists, {:array, :map})
    field(:album, :map)
    field(:duration_ms, :integer)
    field(:uri, :string)
    field(:added_at, :utc_datetime)
    field(:added_by, :string)
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def new(raw_track) do
    # IO.inspect(raw_track, label: "raw_track")
    {:ok, added_at, _} =
      raw_track
      |> Map.get("added_at", "2000-01-01T01:01:01Z")
      |> DateTime.from_iso8601()

    %__MODULE__{
      name: get_in(raw_track, ["track", "name"]),
      artists: get_in(raw_track, ["track", "artists"]),
      album: get_in(raw_track, ["track", "album"]),
      duration_ms: get_in(raw_track, ["track", "duration_ms"]),
      id: get_in(raw_track, ["track", "id"]),
      uri: get_in(raw_track, ["track", "uri"]),
      added_at: added_at,
      added_by: get_in(raw_track, ["added_by", "id"])
    }
  end
end
