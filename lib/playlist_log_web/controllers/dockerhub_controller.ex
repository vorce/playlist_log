defmodule PlaylistLogWeb.DockerhubController do
  use PlaylistLogWeb, :controller

  alias PlaylistLog.Dockerhub

  def webhook(conn, params) do
    with :ok <- validate_key(Map.get(params, "key"), key()),
         :ok <- validate_repo(params),
         :ok <- Dockerhub.update_image(get_in(params, ["push_data", "tag"])) do
      conn
      |> put_status(202)
      |> render("webhook.json", %{
        state: "accepted",
        name: get_in(params, ["repository", "repo_name"])
      })
    else
      {:error, :invalid_key} ->
        conn
        |> put_status(403)
        |> render("webhook.json", %{
          state: "refused",
          name: get_in(params, ["repository", "repo_name"]) || "unknown"
        })

      {:error, :invalid_repo} ->
        conn
        |> put_status(422)
        |> render("webhook.json", %{
          state: "refused",
          name: get_in(params, ["repository", "repo_name"]) || "unknown"
        })

      _error ->
        conn
        |> put_status(500)
        |> render("webhook.json", %{
          state: "failed",
          name: get_in(params, ["repository", "repo_name"]) || "unknown"
        })
    end
  end

  defp validate_key(attempted_key, valid_key) when attempted_key == valid_key, do: :ok
  defp validate_key(_, _), do: {:error, :invalid_key}

  defp validate_repo(%{"repository" => %{"repo_name" => repo_name}})
       when repo_name == "vorce/playlistlog",
       do: :ok

  defp validate_repo(_), do: {:error, :invalid_repo}

  def key() do
    Application.get_env(:playlist_log, __MODULE__)[:key]
  end
end
