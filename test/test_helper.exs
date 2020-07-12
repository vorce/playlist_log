ExUnit.start()
Application.ensure_all_started(:bypass)
path = Application.get_env(:playlist_log, PlaylistLog.Repo)[:data_dir]

with {:ok, files} <- File.ls(path) do
  Enum.each(files, fn file ->
    full_path = Path.join(path, file)
    IO.puts("Deleting file: #{full_path}")
    File.rm(full_path)
  end)
end
