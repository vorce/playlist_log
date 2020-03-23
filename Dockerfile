FROM hexpm/elixir:1.10.2-erlang-22.2.8-alpine-3.11.3 AS build

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# install build dependencies
RUN apk add --update build-base npm git

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
COPY assets assets
COPY priv priv
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# build project
COPY lib lib
RUN mix compile

# build release (uncomment COPY if rel/ exists)
# COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.11.3 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/playlist_log ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app