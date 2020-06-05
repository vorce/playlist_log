defmodule PlaylistLogWeb.LogLiveView do
  use Phoenix.LiveView

  alias PlaylistLog.Playlists.Event

  require Logger

  @initial_event_count 30
  @more_events_increment 30

  def render(assigns) do
    PlaylistLogWeb.LogView.render("events.html", assigns)
  end

  def mount(_params, session, socket) do
    events = Map.fetch!(session, "events")
    show_events = Map.fetch!(session, "show_events")
    events_to_show = @initial_event_count

    assigns = [
      events_to_show: events_to_show,
      events: events,
      show_events: show_events,
      ordered_events: limited_filtered_events(events, show_events, events_to_show)
    ]

    {:ok, assign(socket, assigns), temporary_assigns: [ordered_events: []]}
  end

  def handle_event("event_filter_change", %{"show_events" => show_events}, socket) do
    Logger.debug("Event filter changed, showing #{show_events} events")

    filtered_events =
      limited_filtered_events(
        socket.assigns[:events],
        show_events,
        socket.assigns[:events_to_show]
      )

    {:noreply, assign(socket, show_events: show_events, ordered_events: filtered_events)}
  end

  def handle_event("show_more_events", _, socket) do
    Logger.debug("Loading #{@more_events_increment} more events...")
    events_to_show = socket.assigns[:events_to_show] + @more_events_increment

    filtered_events =
      limited_filtered_events(
        socket.assigns[:events],
        socket.assigns[:show_events],
        events_to_show
      )

    {:noreply, assign(socket, events_to_show: events_to_show, ordered_events: filtered_events)}
  end

  defp limited_filtered_events(events, filter, limit) do
    events
    |> Enum.sort(&Event.latest_first_order/2)
    |> Enum.take(limit)
    |> Event.filtered_events(filter)
  end
end
