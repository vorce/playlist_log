# PlaylistLog

A log / timeline of song additions and removals for a Spotify playlist.

## Workflow

- Sign in to spotify
- Select playlist
- Show current songs in playlist + show events for the playlist (events are either additions or removals of tracks to the playlist)
- Present options to delete and add songs to the playlist, doing this will create new events in the log for that playlist.


## Storage details

CubDB

https://hexdocs.pm/cubdb/howto.html

```elixir
%{
  {:log, user_id, log_id} => %Log{}
  {:event, log_id, Date} => [%Event{}, %Event{}]
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
