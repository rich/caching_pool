defmodule CachingPool.Server.Worker do
  use GenServer
  import CachingPool.Utils

  def start_link(opts, call, pool) do
    GenServer.start_link(__MODULE__, {opts, call, pool}, name: via_tuple(opts, call))
  end
  
  def init({opts, call, pool}) do
    Process.send(self(), {:run, call, pool}, [])

    {:ok, {opts, nil}}
  end

  def handle_cast({:get, from}, {_, val}=state) do
    GenServer.reply(from, val)
    {:noreply, state}
  end

  def handle_info({:run, {func, args}=call, pool}, {opts, _}) do
    :poolboy.transaction(pool, fn worker ->
      val = GenServer.call(worker, {:do, func, args}) |> write_to_ets(call, opts)
      {:noreply, {opts, val}}
    end)
  end

  defp via_tuple(opts, call) do
    {:via, Registry, {registry_name(List.wrap(opts)), call}}
  end

  defp write_to_ets(val, call, opts) do
    opts
      |> table_name
      |> CachingPool.Cache.write(call, val, opts |> get_ttl)
  end
end