defmodule CachingPool.Server do
  use GenServer
  import CachingPool.Utils

  defstruct pool: nil, cache: nil, worker_sup_name: nil

  def start(opts), do: do_start(:start, opts)
  def start_link(opts), do: do_start(:start_link, opts)

  defp do_start(type, opts) do
    name = opts |> name_from_opts
    opts = Keyword.put(opts, :name, name)

    apply(GenServer, type, [__MODULE__, opts, [name: name]])
  end

  def init(opts) do
    {:ok, init_state(opts)}
  end

  def init_state(opts) do
    %__MODULE__{
      pool: new_poolboy(opts),
      cache: new_ets_table(opts),
      worker_sup_name: worker_sup_name(opts)
    }
  end

  def handle_call({:do, func, args}, from, state) do
    queue_call({func, args}, from, state)

    {:noreply, state}
  end

  def queue_call(call, from, state) do
    call
      |> get_worker(state)
      |> GenServer.cast({:get, from})
  end

  def get_worker(call, %{worker_sup_name: name, pool: pool}) do
    case Supervisor.start_child(name, [call, pool]) do
      {:ok, p} -> p
      {:error, {:already_started, p}} -> p
    end
  end

  defp new_ets_table(opts) do
    CachingPool.Cache.new(opts |> table_name)
  end

  def new_poolboy(opts) do
    {:ok, pool} = :poolboy.start_link(poolboy_opts(opts), poolboy_module_opts(opts))

    pool
  end
end
