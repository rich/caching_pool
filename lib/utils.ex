defmodule CachingPool.Utils do
  @table_suffix :table
  @worker_sup_suffix :worker_sup
  @registry_suffix :registry

  @default_poolboy_size 10
  @default_poolboy_max_overflow 10
  @default_ttl 5_000

  def table_name(name) when is_atom(name), do: Module.concat(name, @table_suffix)
  def table_name(opts) when is_list(opts) do
    opts |> name_from_opts |> table_name
  end

  def worker_sup_name(name) when is_atom(name), do: Module.concat(name, @worker_sup_suffix)
  def worker_sup_name(opts) when is_list(opts) do
    opts |> name_from_opts |> worker_sup_name
  end

  def registry_name(name) when is_atom(name), do: Module.concat(name, @registry_suffix)
  def registry_name(opts) when is_list(opts) do
    opts |> name_from_opts |> registry_name
  end

  def server_opts(opts) do
    name = opts |> name_from_opts

    {server_opts, _} = Keyword.split(opts, [:max_concurrency, :module])
    
    [server_opts |> Keyword.put(:name, name)]
  end

  def worker_opts(opts) do
    {worker_opts, _} = Keyword.split(opts, [:name, :module, :ttl])
    [worker_opts]
  end

  def poolboy_opts(opts) do
    max_concurrency = Keyword.get(opts, :max_concurrency, @default_poolboy_size)

    [worker_module: CachingPool.Worker, size: max_concurrency, max_overflow: @default_poolboy_max_overflow]
  end

  def poolboy_module_opts(opts) do
    {module_opts, _} = Keyword.split(opts, [:module])
    module_opts
  end

  def to_call(func, args) when is_atom(func) and is_list(args) do
    {:do, func, args}
  end

  def name_from_opts(opts) do
    Keyword.get(opts, :name, Keyword.get(opts, :module))
  end

  def get_ttl(opts) do
    Keyword.get(opts, :ttl, @default_ttl)
  end
end