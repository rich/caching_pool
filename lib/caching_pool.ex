defmodule CachingPool do
  import CachingPool.Utils, warn: false

  def call(name, func, args \\ [])
  def call(name, func, args) do
    name |> get_value(func, args)
  end

  def get_value(name, func, args) do
    name
      |> table_name
      |> CachingPool.Cache.read({func, args})
      |> get_value(name, func, args)
  end

  def get_value(nil, name, func, args) do
    GenServer.call(name, to_call(func, args))
  end
  def get_value(val, _, _, _), do: val
end