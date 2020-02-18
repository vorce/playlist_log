defmodule PlaylistLog.Playlists.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "logs" do
    field(:name, :string)
    field(:description, :string)
    field(:track_count, :integer)
    field(:external_id, :string)
    field(:collaborative, :boolean)
    field(:owner_id, :string)
    field(:fetched_by, :string)

    has_many(:events, Event)
    has_many(:tracks, Track)

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
      :fetched_by
    ])
    |> validate_required(@required_keys)
  end

  def new(map, fetched_by \\ nil) do
    external_id = map["id"]

    %__MODULE__{
      name: map["name"],
      description: map["description"],
      track_count: get_in(map, ["tracks", "total"]),
      external_id: external_id,
      collaborative: map["collaborative"],
      owner_id: get_in(map, ["owner", "id"]),
      id: external_id,
      fetched_by: fetched_by
    }
  end
end
