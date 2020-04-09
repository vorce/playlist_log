defmodule PlaylistLog.Dockerhub do
  @moduledoc """
  Logic for reacting to webhook requests from dockerhub. Interacts with the Docker API
  using the docker unix socket. (which is expected to be at /var/run/docker.sock)

  Example curls
  - list running containers: `curl -XGET --unix-socket /var/run/docker.sock http://containers/json`
  - list all services: `curl -XGET --unix-socket /var/run/docker.sock http://services`
  """

  require Logger

  @docker_socket "/var/run/docker.sock"
  @socket_path URI.encode_www_form(@docker_socket)
  @protocol "http+unix://"
  @base_url @protocol <> @socket_path

  def update_image("latest") do
    Logger.info("Ignoring dockerhub webhook request for tag 'latest'")
    :ok
  end

  def update_image(tag) do
    with {:ok, service} <- get_service_details(),
         :ok <- update_service(service, tag) do
      :ok
    else
      error ->
        Logger.error("Error when trying to update service, reason: #{inspect(error)}")
        error
    end
  end

  @doc """
  Gets the service details for playlistlog

  Docker API: https://docs.docker.com/engine/api/v1.40/#operation/ServiceList
  """
  def get_service_details() do
    url = @base_url <> "/services"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, services} <- Jason.decode(body) do
      find_service_details(services)
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

  @doc """
  Update a service

  POST /services/(id)/update

  Docker API docs: https://docs.docker.com/engine/api/v1.40/#operation/ServiceUpdate
  """
  def update_service(service, tag, base_url \\ @base_url) do
    id = Map.get(service, "ID")
    version = get_in(service, ["Version", "Index"])
    url = base_url <> "/services/#{id}/update?version=#{version}"
    headers = ["content-type": "application/json"]
    payload = update_payload(service, tag)
    details = [url: url, id: id, version: version, tag: tag, payload: payload]

    case HTTPoison.post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("Successfully updated service, details: #{inspect(details)}")

      unexpected ->
        {:error, :update_service, unexpected}
    end
  end

  defp update_payload(service, tag) do
    service_spec = Map.fetch!(service, "Spec")

    put_in(
      service_spec,
      ["TaskTemplate", "ContainerSpec", "Image"],
      "vorce/playlistlog:#{tag}"
    )
  end
end
