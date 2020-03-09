defmodule PlaylistLog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @cubdb_data_dir Application.get_env(:playlist_log, PlaylistLog.Repo)[:data_dir]

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      CubDB.child_spec(data_dir: @cubdb_data_dir, auto_compact: true, name: :cubdb),
      PlaylistLogWeb.Endpoint
      # Starts a worker by calling: PlaylistLog.Worker.start_link(arg)
      # {PlaylistLog.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlaylistLog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PlaylistLogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
