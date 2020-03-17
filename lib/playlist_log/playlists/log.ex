defmodule PlaylistLog.Playlists.Log do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlaylistLog.Playlists.Event
  alias PlaylistLog.Playlists.Track

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "logs" do
    field(:name, :string)
    field(:description, :string)
    field(:track_count, :integer, default: 0)
    field(:external_id, :string)
    field(:collaborative, :boolean)
    field(:owner_id, :string)
    field(:fetched_by, :string)
    field(:event_count, :integer, default: 0)
    field(:snapshot_id, :string)

    has_many(:events, Event)
    has_many(:tracks, Track, on_replace: :delete)

    timestamps()
  end

  @required_keys [:name, :track_count, :external_id, :collaborative, :owner_id]

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :name,
      :description,
      :track_count,
      :external_id,
      :collaborative,
      :owner_id,
      :fetched_by,
      :event_count,
      :snapshot_id
    ])
    |> cast_assoc(:events, with: &Event.changeset/2)
    |> cast_assoc(:tracks, with: &Track.changeset/2)
    |> validate_required(@required_keys)
  end

  def new(map, opts \\ []) do
    external_id = map["id"]

    %__MODULE__{
      name: map["name"],
      description: map["description"],
      track_count: get_in(map, ["tracks", "total"]),
      external_id: external_id,
      collaborative: map["collaborative"] || false,
      owner_id: get_in(map, ["owner", "id"]),
      id: external_id,
      fetched_by: Keyword.get(opts, :fetched_by),
      event_count: Keyword.get(opts, :event_count, 0),
      snapshot_id: map["snapshot_id"]
    }
  end
end
