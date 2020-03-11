# PlaylistLog

A log / timeline of song additions and removals for a Spotify playlist.

I use this to keep a sliding window of around 50 tracks that I dig at the moment.
By using PlaylistLog I get a nice historic timelime of previous tracks that was part
of the playlist at some point.

## Workflow

- Sign in to spotify
- Load playlists from Spotify (only needed the first time or if you make updates to playlists like name, description)
- Choose playlist
- Overview of current songs in playlist + changes for the playlist (changes are either track additions or removals)
- In the playlist overview you can add and delete tracks to/from the playlist, doing this will create new changes/events.

## TODO

- Enable users to filter changes/events by type

## Storage details

CubDB

https://hexdocs.pm/cubdb/howto.html

```elixir
%{
  {:log, <user-id>, <log-id>} => %Log{}
  {:event, <log-id>, <date-string>} => [%Event{}, %Event{}]
}
```

---

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
