FROM hexpm/elixir:1.14.5-erlang-25.3.2-ubuntu-jammy-20230126

RUN apt-get update && \
    apt-get install -y build-essential git nodejs npm imagemagick && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY . .

RUN mix deps.get

RUN MIX_ENV=prod mix compile
RUN mix assets.deploy

RUN MIX_ENV=prod mix phx.digest
RUN MIX_ENV=prod mix release

EXPOSE 4000

ENV MIX_ENV=prod

CMD _build/prod/rel/guess_pokemon/bin/migrate && \
    _build/prod/rel/guess_pokemon/bin/server