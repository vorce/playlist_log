defmodule PlaylistLog.SpotifyTest do
  use ExUnit.Case

  alias PlaylistLog.Spotify

  describe "validate_uri/1" do
    test "returns {:ok, :track} for valid track uri" do
      uri = "spotify:track:7lEptt4wbM0yJTvSG5EBof"
      assert {:ok, :track} == Spotify.validate_uri(uri)
    end

    test "returns {:error, :invalid_format} for invalid uri" do
      uri = "https://www.google.com/track/1234"
      assert {:error, :invalid_format} == Spotify.validate_uri(uri)
    end
  end
end
