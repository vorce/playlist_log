defmodule PlaylistLog.Playlists.Track do
  @moduledoc """
  Playlists contains Tracks. A track can for example be a song + artist, and other metadata.
  (it could also be a podcast episode, etc.)
  """
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
    field(:log_id, :string)
  end

  @doc false
  def changeset(track, %__MODULE__{} = attrs) do
    changeset(track, Map.from_struct(attrs))
  end

  def changeset(track, %{} = attrs) do
    track
    |> cast(attrs, [:name, :artists, :album, :duration_ms, :uri, :added_at, :added_by, :log_id])
    |> validate_required([:uri])
  end

  def new(raw_track) do
    {:ok, added_at, _} =
      raw_track
      |> Map.get("added_at", "2000-01-01T01:01:01Z")
      |> DateTime.from_iso8601()

    %__MODULE__{
      name: get_in(raw_track, ["track", "name"]),
      artists: get_in(raw_track, ["track", "artists"]),
      album: get_in(raw_track, ["track", "album"]),
      duration_ms: get_in(raw_track, ["track", "duration_ms"]),
      id: UUID.uuid1(),
      uri: get_in(raw_track, ["track", "uri"]),
      added_at: added_at,
      added_by: get_in(raw_track, ["added_by", "id"])
    }
  end

  def artist_string(%{artists: artists}) do
    artist_string(%{"artists" => artists})
  end

  def artist_string(%{"artists" => nil}), do: ""

  def artist_string(%{"artists" => artists}) do
    Enum.map_join(artists, ", ", fn artist -> artist["name"] end)
  end
end
