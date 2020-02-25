defmodule PlaylistLog.PlaylistsTest do
  use ExUnit.Case
  alias PlaylistLog.Playlists

  describe "logs" do
    alias PlaylistLog.Playlists.Log

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def log_fixture(attrs \\ %{}) do
      {:ok, log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Playlists.create_log()

      log
    end

    # test "list_logs/0 returns all logs" do
    #   log = log_fixture()
    #   assert Playlists.list_logs() == [log]
    # end

    # test "get_log!/1 returns the log with given id" do
    #   log = log_fixture()
    #   assert Playlists.get_log!(log.id) == log
    # end

    # test "create_log/1 with valid data creates a log" do
    #   assert {:ok, %Log{} = log} = Playlists.create_log(@valid_attrs)
    #   assert log.name == "some name"
    # end

    # test "create_log/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Playlists.create_log(@invalid_attrs)
    # end

    # test "update_log/2 with valid data updates the log" do
    #   log = log_fixture()
    #   assert {:ok, %Log{} = log} = Playlists.update_log(log, @update_attrs)
    #   assert log.name == "some updated name"
    # end

    # test "update_log/2 with invalid data returns error changeset" do
    #   log = log_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Playlists.update_log(log, @invalid_attrs)
    #   assert log == Playlists.get_log!(log.id)
    # end

    # test "delete_log/1 deletes the log" do
    #   log = log_fixture()
    #   assert {:ok, %Log{}} = Playlists.delete_log(log)
    #   assert_raise Ecto.NoResultsError, fn -> Playlists.get_log!(log.id) end
    # end

    # test "change_log/1 returns a log changeset" do
    #   log = log_fixture()
    #   assert %Ecto.Changeset{} = Playlists.change_log(log)
    # end
  end
end
