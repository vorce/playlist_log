defmodule PlaylistLog.DockerhubTest do
  use ExUnit.Case

  alias PlaylistLog.Dockerhub

  @example_services """
  [
    {
      "ID": "3th47x8a8fouz13vl169pbsfw",
      "Version": {
          "Index": 565
      },
      "CreatedAt": "2020-03-27T16:45:00.144045064Z",
      "UpdatedAt": "2020-03-27T20:46:30.704189442Z",
      "Spec": {
          "Name": "playlistlog",
          "Labels": {},
          "TaskTemplate": {
              "ContainerSpec": {
                  "Image": "vorce/playlistlog:91469526a32a8d04fa85f4c5b05078e149697669@sha256:2c54a517721f0183ca69dc4472d22d72e4f809ac84ead00293894acba16dfc2b",
                  "Args": [
                      "/app/bin/playlist_log",
                      "start"
                  ],
                  "Env": [
                      "SECRET_KEY_BASE=...",
                      "SPOTIFY_CLIENT_ID=...",
                      "SPOTIFY_CLIENT_SECRET=...",
                      "SPOTIFY_REDIRECT_URI=https://playlistlog.vorce.se/spotify_callback"
                  ],
                  "Init": false,
                  "Mounts": [
                      {
                          "Type": "bind",
                          "Source": "/home/joel/playlist_log/data_dir",
                          "Target": "/app/priv/cubdb"
                      }
                  ],
                  "DNSConfig": {},
                  "Isolation": "default"
              },
              "Resources": {
                  "Limits": {},
                  "Reservations": {}
              },
              "Placement": {
                  "Platforms": [
                      {
                          "Architecture": "amd64",
                          "OS": "linux"
                      }
                  ]
              },
              "ForceUpdate": 0,
              "Runtime": "container"
          },
          "Mode": {
              "Replicated": {
                  "Replicas": 1
              }
          },
          "UpdateConfig": {
              "Parallelism": 1,
              "Delay": 10000000000,
              "FailureAction": "pause",
              "Monitor": 5000000000,
              "MaxFailureRatio": 0,
              "Order": "stop-first"
          },
          "EndpointSpec": {
              "Mode": "vip",
              "Ports": [
                  {
                      "Protocol": "tcp",
                      "TargetPort": 4000,
                      "PublishedPort": 4000,
                      "PublishMode": "ingress"
                  }
              ]
          }
      },
      "PreviousSpec": {
          "Name": "playlistlog",
          "Labels": {},
          "TaskTemplate": {
              "ContainerSpec": {
                  "Image": "vorce/playlistlog:91469526a32a8d04fa85f4c5b05078e149697669@sha256:2c54a517721f0183ca69dc4472d22d72e4f809ac84ead00293894acba16dfc2b",
                  "Args": [
                      "/app/bin/playlist_log",
                      "start"
                  ],
                  "Env": [
                      "SECRET_KEY_BASE=...",
                      "SPOTIFY_CLIENT_ID=...",
                      "SPOTIFY_CLIENT_SECRET=...",
                      "SPOTIFY_REDIRECT_URI=https://playlistlog.vorce.se/spotify_callback"
                  ],
                  "Init": false,
                  "Mounts": [
                      {
                          "Type": "bind",
                          "Source": "/playlist_log/data_dir",
                          "Target": "/app/priv/cubdb"
                      }
                  ],
                  "DNSConfig": {},
                  "Isolation": "default"
              },
              "Resources": {
                  "Limits": {},
                  "Reservations": {}
              },
              "Placement": {
                  "Platforms": [
                      {
                          "Architecture": "amd64",
                          "OS": "linux"
                      }
                  ]
              },
              "ForceUpdate": 0,
              "Runtime": "container"
          },
          "Mode": {
              "Replicated": {
                  "Replicas": 0
              }
          },
          "UpdateConfig": {
              "Parallelism": 1,
              "Delay": 10000000000,
              "FailureAction": "pause",
              "Monitor": 5000000000,
              "MaxFailureRatio": 0,
              "Order": "stop-first"
          },
          "EndpointSpec": {
              "Mode": "vip",
              "Ports": [
                  {
                      "Protocol": "tcp",
                      "TargetPort": 4000,
                      "PublishedPort": 4000,
                      "PublishMode": "ingress"
                  }
              ]
          }
      },
      "Endpoint": {
          "Spec": {
              "Mode": "vip",
              "Ports": [
                  {
                      "Protocol": "tcp",
                      "TargetPort": 4000,
                      "PublishedPort": 4000,
                      "PublishMode": "ingress"
                  }
              ]
          },
          "Ports": [
              {
                  "Protocol": "tcp",
                  "TargetPort": 4000,
                  "PublishedPort": 4000,
                  "PublishMode": "ingress"
              }
          ],
          "VirtualIPs": [
              {
                  "NetworkID": "gyng5inzr7f3curhnds6zg9kh",
                  "Addr": "10.0.0.33/24"
              }
          ]
      }
    }
  ]
  """

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "find_service_details/1" do
    test "gets playlistlog service" do
      assert {:ok, %{}} = Dockerhub.find_service_details(Jason.decode!(@example_services))
    end

    test "returns error tuple when no playlistlog service exists" do
      services =
        @example_services
        |> Jason.decode!()
        |> hd()
        |> put_in(["Spec", "Name"], "Foo")
        |> List.wrap()

      assert Dockerhub.find_service_details(services) == {:error, :no_playlistlog_service}
    end
  end

  describe "update_service/4" do
    test "posts payload to docker API", %{bypass: bypass} do
      id = "3th47x8a8fouz13vl169pbsfw"
      version = 565
      new_tag = "tag1"
      base_url = "http://localhost:#{bypass.port}"

      Bypass.expect_once(bypass, fn conn ->
        assert conn.request_path == "/services/#{id}/update"
        assert conn.query_string == "version=#{version}"

        {:ok, body, conn} = Plug.Conn.read_body(conn)
        payload = Jason.decode!(body)
        image = get_in(payload, ["TaskTemplate", "ContainerSpec", "Image"])

        assert image == "vorce/playlistlog:#{new_tag}"

        Plug.Conn.resp(conn, 200, "OK")
      end)

      service = @example_services |> Jason.decode!() |> hd()
      assert Dockerhub.update_service(service, new_tag, base_url) == :ok
    end
  end
end
