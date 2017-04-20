defmodule CachingPool.Supervisor do
  use Supervisor
  import CachingPool.Utils
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [])
  end
  
  def init(opts) do
    import Supervisor.Spec, warn: false
    
    children = [
      supervisor(Registry, [:unique, registry_name(opts)]),
      supervisor(CachingPool.Server.WorkerSupervisor, worker_opts(opts)),
      worker(CachingPool.Server, server_opts(opts))
    ]
    
    supervise(children, strategy: :one_for_one)
  end
end