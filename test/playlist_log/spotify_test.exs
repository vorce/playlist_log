defmodule PlaylistLog.SpotifyTest do
  use ExUnit.Case

  alias PlaylistLog.Spotify

  describe "validate_uri/1" do
    test "returns {:ok, {:track, uri}} for valid track uri" do
      uri = "spotify:track:7lEptt4wbM0yJTvSG5EBof"
      assert {:ok, {:track, uri}} == Spotify.validate_uri(uri)
    end

    test "returns {:error, :invalid_format} for invalid uri" do
      uri = "https://www.google.com/track/1234"
      assert {:error, :invalid_format} == Spotify.validate_uri(uri)
    end
  end

  describe "validate_link/1" do
    test "returns {:ok, track} for valid track link" do
      link = "https://open.spotify.com/track/2azLsNFfIPtxNU4QmJzPow?si=85f957ef77854352"
      uri = "spotify:track:2azLsNFfIPtxNU4QmJzPow"
      assert {:ok, uri} == Spotify.validate_link(link)
    end
  end
end
