# ESClient

[![Build Status](https://travis-ci.org/tlux/es_client.svg?branch=master)](https://travis-ci.org/tlux/es_client)
[![Hex.pm](https://img.shields.io/hexpm/v/es_client.svg)](https://hex.pm/packages/es_client)

A minimalistic Elasticsearch client for Elixir.

## Prerequisites

* Elixir >= 1.8
* Erlang >= 20

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `es_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:es_client, "~> 0.1"},

    # You will also need a JSON library
    {:jason, "~> 1.1"}
  ]
end
```

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found at
[https://hexdocs.pm/es_client](https://hexdocs.pm/es_client).

## Usage

You can call the client directly if you have a config struct.

```elixir
config = %ESClient.Config{base_url: "http://localhost:9201"}
ESClient.get!(config, "_cat/health")
```

It's also possible to pass a list of path segments.

```elixir
ESClient.get!(config, ["_cat", "health"])
```

When the location is a tuple, the second element becomes encoded as query
params.

```elixir
ESClient.get!(config, {["_cat", "health"], verbose: true})
```

Or you can `use` this module to build your own custom client and obtain values
from the application config.

```elixir
defmodule MyCustomClient
  use ESClient, otp_app: :my_app
end
```

Don't forget to add the configuration to your config.exs.

```elixir
use Mix.Config
# or
import Config

config :my_app, MyCustomClient,
  base_url: "http://localhost:9201",
  json_keys: :atoms,
  json_library: Jason,
  timeout: 15_000
```

Then, use your client.

```elixir
MyCustomClient.get!("_cat/health")
```

## Missing Features

* Authentication
