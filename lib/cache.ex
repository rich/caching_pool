defmodule CachingPool.Cache do
  def new(name) do
    :ets.new(name, [:named_table, :public, write_concurrency: true, read_concurrency: true])
  end

  def write(name, key, val, ttl) do
    :ets.insert(name, {key, {val, system_time() + ttl}})

    val
  end

  def read(name, key) do
    :ets.lookup(name, key)
      |> check(name)
  end

  defp check([], _), do: nil
  defp check([{key, {val, expiration}}], name) do
    case expiration >= system_time() do
      true -> val
      false ->
        :ets.delete(name, key)
        nil
    end
  end

  defp system_time, do: :os.system_time(:milli_seconds)
end