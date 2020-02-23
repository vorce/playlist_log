defmodule PlaylistLogWeb.LogView do
  use PlaylistLogWeb, :view

  @minute_in_seconds 60

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
