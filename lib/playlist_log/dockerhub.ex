defmodule PlaylistLog.Dockerhub do
  @moduledoc """
  Logic for reacting to webhook requests from dockerhub.
  """

  require Logger

  @doc """
  Update a service

  POST /services/(id)/update

  Update a service. https://docs.docker.com/engine/api/v1.40/#operation/ServiceUpdate

  Example curls
  - list running containers: `curl -XGET --unix-socket /var/run/docker.sock http://localhost/containers/json`
  - list all services: `curl -XGET --unix-socket /var/run/docker.sock http://localhost/services`
  """

  @docker_socket "/var/run/docker.sock"
  @socket_path URI.encode_www_form(@docker_socket)

  def update_image("latest") do
    Logger.info("Ignoring dockerhub webhook request for tag 'latest'")
    :ok
  end

  def update_image(tag) do
    with {:ok, id, version} <- get_service_details(),
         :ok <- update_service(id, version, tag) do
      :ok
    else
      error ->
        Logger.error("Error when trying to update service, reason: #{inspect(error)}")
        error
    end
  end

  @protocol "http+unix://"
  def get_service_details() do
    url = @protocol <> @socket_path <> "/services"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, services} <- Jason.decode(body),
         {:ok, service} <- find_service_details(services) do
      {:ok, Map.get(service, "ID"), get_in(service, ["Version", "Index"])}
    else
      unexpected -> {:error, :get_service_details, unexpected}
    end
  end

  def find_service_details(services) do
    Enum.find_value(services, {:error, :no_playlistlog_service}, fn service ->
      if get_in(service, ["Spec", "Name"]) == "playlistlog" do
        {:ok, service}
      end
    end)
  end

  def update_service(id, version, tag) do
    url = @protocol <> @socket_path <> "/services/#{id}/update?version=#{version}"
    headers = ["content-type": "application/json"]
    payload = update_payload(tag)
    details = [url: url, id: id, version: version, tag: tag, payload: payload]

    case HTTPoison.post(url, headers, payload) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("Successfully updated service, details: #{inspect(details)}")

      unexpected ->
        {:error, :update_service, unexpected}
    end
  end

  defp update_payload(tag) do
    %{
      "Name" => "playlistlog",
      "TaskTemplate" => %{
        "ContainerSpec" => %{
          "Image" => "vorce/playlistlog:#{tag}"
        }
      },
      "UpdateConfig" => %{
        "Order" => "start-first"
      }
    }
  end
end
