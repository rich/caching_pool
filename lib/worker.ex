defmodule CachingPool.Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    {:ok, opts |> Keyword.get(:module)}
  end

  def handle_call({:do, func, args}, _from, module) do
    {:reply, apply(module, func, args), module}
  end
end