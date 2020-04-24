defmodule PlaylistLogWeb.LogLiveView do
  use Phoenix.LiveView

  alias PlaylistLog.Playlists.Event

  require Logger

  def render(assigns) do
    PlaylistLogWeb.LogView.render("events.html", assigns)
  end

  def mount(_params, session, socket) do
    events = Map.fetch!(session, "events")
    show_events = Map.fetch!(session, "show_events")

    assigns = [
      events: events,
      show_events: show_events,
      ordered_events: Event.filtered_events(events, show_events)
    ]

    {:ok, assign(socket, assigns), temporary_assigns: [ordered_events: []]}
  end

  def handle_event("event_filter_change", %{"show_events" => show_events}, socket) do
    Logger.debug("Event filter changed, showing #{show_events} events")

    filtered_events = Event.filtered_events(socket.assigns[:events], show_events)

    {:noreply, assign(socket, show_events: show_events, ordered_events: filtered_events)}
  end
end
