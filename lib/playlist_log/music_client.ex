defmodule PlaylistLog.MusicClient do
  @moduledoc """
  Client behaviour for a music platform
  """

  @callback get_playlists(access_token :: String.t()) ::
              {:ok, list(Map.t())} | {:error, {Module.t(), any}}
end
