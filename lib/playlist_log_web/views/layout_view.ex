defmodule PlaylistLogWeb.LayoutView do
  use PlaylistLogWeb, :view

  @doc """
  Renders subtitle suffix if it exists
  """
  def render_subtitle(conn) do
    case conn.assigns[:subtitle] do
      nil -> ""
      subtitle -> " - #{subtitle}"
    end
  end
end
