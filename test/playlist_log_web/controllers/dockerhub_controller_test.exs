defmodule PlaylistLogWeb.DockerhubControllerTest do
  use PlaylistLogWeb.ConnCase

  @example_payload """
  {
    "callback_url": "https://registry.hub.docker.com/u/svendowideit/testhook/hook/2141b5bi5i5b02bec211i4eeih0242eg11000a/",
    "push_data": {
      "images": [
        "27d47432a69bca5f2700e4dff7de0388ed65f9d3fb1ec645e2bc24c223dc1cc3",
        "51a9c7c1f8bb2fa19bcd09789a34e63f35abb80044bc10196e304f6634cc582c",
        "..."
      ],
      "pushed_at": 1417566161,
      "pusher": "trustedbuilder",
      "tag": "latest"
    },
    "repository": {
      "comment_count": 0,
      "date_created": 1417494799,
      "description": "",
      "dockerfile": "",
      "full_description": "Docker Hub based automated build from a GitHub repo",
      "is_official": false,
      "is_private": true,
      "is_trusted": true,
      "name": "testhook",
      "namespace": "svendowideit",
      "owner": "svendowideit",
      "repo_name": "svendowideit/testhook",
      "repo_url": "https://registry.hub.docker.com/u/svendowideit/testhook/",
      "star_count": 0,
      "status": "Active"
    }
  }
  """

  @playlist_log """
  {
    "callback_url": "https://registry.hub.docker.com/u/vorce/playlistlog/hook/2141b5bi5i5b02bec211i4eeih0242eg11000a/",
    "push_data": {
      "images": [
        "27d47432a69bca5f2700e4dff7de0388ed65f9d3fb1ec645e2bc24c223dc1cc3",
        "51a9c7c1f8bb2fa19bcd09789a34e63f35abb80044bc10196e304f6634cc582c",
        "..."
      ],
      "pushed_at": 1417566161,
      "pusher": "vorce",
      "tag": "latest"
    },
    "repository": {
      "comment_count": 0,
      "date_created": 1417494799,
      "description": "",
      "dockerfile": "",
      "full_description": "Docker Hub based automated build from a GitHub repo",
      "is_official": false,
      "is_private": true,
      "is_trusted": true,
      "name": "playlistlog",
      "namespace": "vorce",
      "owner": "vorce",
      "repo_name": "vorce/playlistlog",
      "repo_url": "https://registry.hub.docker.com/u/vorce/playlistlog/",
      "star_count": 0,
      "status": "Active"
    }
  }
  """
  describe "POST /api/dockerhub" do
    test "returns 202 with correct key and repo", %{conn: conn} do
      key = PlaylistLogWeb.DockerhubController.key()

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/dockerhub?key=#{key}", @playlist_log)

      assert json_response(conn, 202) == %{
               "name" => "vorce/playlistlog",
               "state" => "accepted"
             }
    end

    test "returns 403 with wrong key", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/dockerhub?key=123", @example_payload)

      assert json_response(conn, 403) == %{
               "name" => "svendowideit/testhook",
               "state" => "refused"
             }
    end

    test "returns 403 with no key", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/dockerhub", @example_payload)

      assert json_response(conn, 403) == %{
               "name" => "svendowideit/testhook",
               "state" => "refused"
             }
    end

    test "returns 422 with correct key but wrong repo", %{conn: conn} do
      key = PlaylistLogWeb.DockerhubController.key()

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/dockerhub?key=#{key}", @example_payload)

      assert json_response(conn, 422) == %{
               "name" => "svendowideit/testhook",
               "state" => "refused"
             }
    end
  end
end
