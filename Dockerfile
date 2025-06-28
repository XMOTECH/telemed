# Use the official Elixir image as a base
FROM elixir:1.15-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

# Set working directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy config files
COPY config/config.exs config/${MIX_ENV}.exs config/
COPY config/runtime.exs config/

# Copy assets
COPY priv priv
COPY assets assets

# Compile assets
RUN mix assets.deploy

# Compile the release
COPY lib lib
RUN mix do compile, release

# Start a new build stage
FROM alpine:3.18 AS runner

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /app

# Create a non-root user
RUN adduser -D -s /bin/sh elixir

# Copy the release from the builder stage
COPY --from=builder --chown=elixir:elixir /app/_build/prod/rel/telemed ./

# Switch to the elixir user
USER elixir

# Set the run command
CMD ["bin/telemed", "start"] 