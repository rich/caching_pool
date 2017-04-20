# CachingPool

Wraps a given module with a caching pool. This handles a very specific use case I encountered a lot. Given a particular module, every function call made to it with identical arguments should trigger only one call with all of the calls receiving the same response. Additionally, there should be a maximum number of concurrent requests with differing arguments. This is primarily useful with remote APIs.

## Basic Usage

```elixir
{:ok, _} = CachingPool.Supervisor.start_link(module: :hackney, max_concurrency: 2, ttl: 50)

# makes an http request to www.apple.com
CachingPool.call(:hackney, :request, ["http://www.apple.com"])

# retrieves the previously cached result
CachingPool.call(:hackney, :request, ["http://www.apple.com"])

# makes an http request to www.cnn.com
CachingPool.call(:hackney, :request, ["http://www.cnn.com"])
```

## `Easy` Macro Usage

```elixir
defmodule WrappedAPI do
  use CachingPool.Easy, module: :hackney, ttl: 500, max_concurrency: 2
end

{:ok, _} = WrappedAPI.start_link

# makes an http request to www.apple.com
WrappedAPI.request("http://www.apple.com")

# makes an http request to www.cnn.com
WrappedAPI.request("http://www.cnn.com")

# retrieves the previously cached result
WrappedAPI.request("http://www.apple.com")
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `caching_pool` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:caching_pool, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/caching_pool](https://hexdocs.pm/caching_pool).

