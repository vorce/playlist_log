# Playlistlog

Playlistlog is a tool to manage your Spotify playlists with.
The primary purpose is to provide a log / timeline of song additions and removals for a Spotify playlist.

I use this to keep a sliding window of around [50 tracks](https://open.spotify.com/playlist/3AecNkQNg9GhbYLV9G3z85?si=dxvTMROhSuyUS2LODNi7lQ) that I dig at the moment.
By using Playlistlog I get a nice historic timelime of songs that was part
of the playlist previously at some point. This is useful for me to just be able to look back at what I liked
a year ago or whatever.

There is currently a public running instance of Playlistlog on https://playlistlog.vorce.se but it should be fairly easy to self host (see the Docker section).

## Workflow

- Sign in to spotify
- Load playlists from Spotify (only needed the first time or if you make updates to playlists like name, description)
- Choose playlist
- Overview of current songs in playlist + changes for the playlist (changes are either track additions or removals)
- In the playlist overview you can add and delete tracks to/from the playlist, doing this will create new changes/events.

## Docker

Docker images are published to: https://hub.docker.com/r/vorce/playlistlog

Example run:
```bash
docker run --name playlistlog -d -p 4000:4000 -e SECRET_KEY_BASE=... -e SPOTIFY_CLIENT_ID=... -e SPOTIFY_CLIENT_SECRET=... -e SPOTIFY_REDIRECT_URI=http://localhost:4000/spotify_callback -v /var/run/docker.sock:/var/run/docker.sock vorce/playlistlog:latest /app/bin/playlist_log start
```

## Data export + import

Example of exporting all events for a log with id "logid", and importing them elsewhere.

### Export

From an iex session:

```elixir
{:ok, events} = PlaylistLog.Repo.all(PlaylistLog.Playlists.Event, "logid")
events_binary = :erlang.term_to_binary(events)
File.write("myexport.txt", events_binary)
```

### Import

Iex again:

```elixir
events_binary = File.read!("myexport.txt")
events = :erlang.binary_to_term(events_binary)
Enum.each(events, fn e -> PlaylistLog.Repo.insert(PlaylistLog.Playlists.Event, "logid", e) end)
```

## TODO

See [github issues](https://github.com/vorce/playlist_log/issues)


## Storage details

CubDB

https://hexdocs.pm/cubdb/howto.html

```elixir
%{
  {:log, <user-id>, <log-id>} => %Log{}
  {:event, <log-id>, <date-string>} => [%Event{}, %Event{}]
}
```

## Screenshot

![Playlistlog screenshot](playlistlog_screenshot_2020-03-24.png?raw=true)
