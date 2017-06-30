defmodule CachingPool.Easy do
  @moduledoc """
  Documentation for CachingPool.
  """
  
  @skip_list [:__info__, :module_info]
  
  defmacro __using__(opts \\ []) do
    module = opts |> Keyword.get(:module) |> Macro.expand(__CALLER__)
    calls = module |> get_module_calls
    name = Keyword.get(opts, :name, module)
    max_concurrency = Keyword.get(opts, :max_concurrency, 10)
    ttl = Keyword.get(opts, :ttl)
    
    start_opts = [name: name, module: module, max_concurrency: max_concurrency, ttl: ttl]
    
    quote bind_quoted: [calls: calls, module: module, proc_name: name, start_opts: start_opts] do
      def start_link(opts \\ [])
      def start_link(_) do
        CachingPool.Supervisor.start_link(unquote(start_opts))
      end
      
      for call <- calls, {name, args, _, _} <- List.wrap(Kernel.Utils.defdelegate(CachingPool.Easy.to_quoted(call), [])) do
        def unquote(name)(unquote_splicing(args)) do
          CachingPool.call(unquote(proc_name), unquote(name), [unquote_splicing(args)])
        end
      end
    end
  end
  
  defp get_module_calls(module) do
    module.module_info()
    |> Keyword.get(:exports)
    |> Enum.reject(fn {k, _} -> k in @skip_list end)
    |> Enum.map(&make_call/1)
  end
  
  defp make_call({name, arity}) do
    args = arity |> arity_to_args
    
    "#{name}(#{args})"
  end
  
  defp arity_to_args(n, acc \\ [])
  
  defp arity_to_args(0, acc), do: acc |> Enum.reverse |> Enum.join(", ")
  defp arity_to_args(n, acc), do: arity_to_args(n - 1, ['arg#{n}' | acc])
  
  def to_quoted(s) do
    {:ok, quoted} = Code.string_to_quoted(s)
    quoted
  end
end