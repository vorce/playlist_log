defmodule PlaylistLog.Playlists.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlaylistLog.Playlists.Track

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "events" do
    field(:name, :string)
    has_one(:track, Track)

    timestamps()
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
