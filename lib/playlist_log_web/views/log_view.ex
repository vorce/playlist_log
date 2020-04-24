defmodule PlaylistLogWeb.LogView do
  use PlaylistLogWeb, :view

  @minute_in_seconds 60

  @doc """
  Render an event
  """
  def render_event(event) do
    time_string = Time.to_iso8601(event.timestamp)
    {icon, description, class} = event_style(event, time_string)
    icon_title = description |> String.split() |> Enum.take(2) |> Enum.join(" ")

    content_tag :div,
      class: "card",
      id: "event-#{event.type}-#{DateTime.to_iso8601(event.timestamp)}" do
      [
        content_tag :div, class: "card-header" do
          [
            img_tag(icon, class: "card-header-icon event-icon #{class}", title: icon_title),
            content_tag :h5 do
              [
                content_tag(:a, "#{event.track_artist} - #{event.track_name} ",
                  href: event.track_uri
                )
              ]
            end
          ]
        end,
        content_tag :div, class: "card-content" do
          [
            content_tag(:p, description)
            #  link(
            #    content_tag(:button, "+ add again", class: "button button-clear"),
            #    to: Routes.log_path(@conn, :add_track, event.log_id, %{"track" => %{"uri" => event.track_uri}}),
            #    method: :post,
            #    data: [confirm: "Are you sure you want to add this song to the playlist?"],
            #    title: "Add track to playlist",
            #    class: "add-track align-right"
            #  )
          ]
        end
      ]
    end
  end

  defp event_style(%{type: "TRACK_ADDED", user: user}, time_string) do
    {
      "/images/icon_add.svg",
      "Track added at #{time_string} by #{user}",
      "icon-green"
    }
  end

  defp event_style(%{type: "TRACK_REMOVED", user: user}, time_string) do
    {
      "/images/icon_cancel.svg",
      "Track removed at #{time_string} by #{user}",
      "icon-red"
    }
  end

  @doc """
  Format a ms integer to "mm:ss" format.
  """
  def format_duration(duration_ms) when is_integer(duration_ms) do
    duration_seconds = div(duration_ms, 1_000)
    minutes = div(duration_seconds, @minute_in_seconds)

    seconds =
      duration_seconds
      |> rem(@minute_in_seconds)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{minutes}:#{seconds}"
  end
end
