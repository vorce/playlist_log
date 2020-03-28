defmodule PlaylistLogWeb.DockerhubView do
  use PlaylistLogWeb, :view

  def render("webhook.json", %{state: state, name: name}) do
    %{state: state, name: name}
  end
end
