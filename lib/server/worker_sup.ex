defmodule CachingPool.Server.WorkerSupervisor do
  use Supervisor
  import CachingPool.Utils

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: worker_sup_name(opts))
  end
  
  def init(opts) do
    import Supervisor.Spec, warn: false

    children = [
      worker(CachingPool.Server.Worker, [opts])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end