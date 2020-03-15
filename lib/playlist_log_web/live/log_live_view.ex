defmodule PlaylistLogWeb.LogLiveView do
  use Phoenix.LiveView

  alias PlaylistLog.Playlists.Event

  require Logger

  def render(assigns) do
    PlaylistLogWeb.LogView.render("events.html", assigns)
  end

  def mount(_params, session, socket) do
    assigns = [
      events: Map.fetch!(session, "events"),
      ordered_events: Map.fetch!(session, "ordered_events"),
      show_events: Map.fetch!(session, "show_events")
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("event_filter_change", %{"show_events" => show_events}, socket) do
    Logger.debug("Event filter changed, showing #{show_events} events")

    filtered_events =
      case show_events do
        "all" ->
          Event.order_by_date(socket.assigns[:events])

        "additions" ->
          socket.assigns[:events]
          |> Enum.filter(fn event -> event.type == "TRACK_ADDED" end)
          |> Event.order_by_date()

        "removals" ->
          socket.assigns[:events]
          |> Enum.filter(fn event -> event.type == "TRACK_REMOVED" end)
          |> Event.order_by_date()
      end

    {:noreply, assign(socket, show_events: show_events, ordered_events: filtered_events)}
  end

  # def handle_info({Lasso, _uuid, {:request, request}}, socket) do
  #   all_requests = Enum.take([request | socket.assigns.requests], @request_limit)
  #   {:noreply, assign(socket, :requests, all_requests)}
  # end

  # def handle_info({Lasso, _uuid, :clear}, socket) do
  #   {:noreply, assign(socket, :requests, [])}
  # end

  # def handle_info({Lasso, _uuid, :delete}, socket) do
  #   {:noreply, redirect(socket, to: "/")}
  # end

  # def handle_event("clear", _, %{assigns: %{uuid: uuid}} = socket) do
  #   Logger.info("Clearing requests for lasso with uuid: #{uuid}")
  #   socket = clear(socket, uuid)
  #   {:noreply, assign(socket, :requests, [])}
  # end

  # def handle_event("delete", _, %{assigns: %{uuid: uuid}} = socket) do
  #   Logger.info("Deleting lasso with uuid: #{uuid}")

  #   socket =
  #     socket
  #     |> delete(uuid)
  #     |> redirect(to: "/")

  #   {:noreply, socket}
  # end

  # defp clear(socket, uuid) do
  #   case Lasso.clear(uuid) do
  #     :ok ->
  #       put_flash(socket, :info, "Successfully cleared lasso: #{uuid}")

  #     error ->
  #       put_flash(socket, :error, "Failed to clear lasso #{uuid}, due to: #{inspect(error)}")
  #   end
  # end

  # defp delete(socket, uuid) do
  #   case Lasso.delete(uuid) do
  #     :ok ->
  #       put_flash(socket, :info, "Successfully deleted lasso: #{uuid}")

  #     error ->
  #       put_flash(socket, :error, "Failed to delete lasso #{uuid}, due to: #{inspect(error)}")
  #   end
  # end
end
