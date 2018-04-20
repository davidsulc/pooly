defmodule Pooly do
  use Application

  def start(_type, _args) do
    pool_config = [
      worker_sup_mod: Pooly.WorkerSupervisor,
      worker_spec: Pooly.SampleWorker,
      size: 5
    ]
    start_pool(pool_config)
  end

  defdelegate start_pool(pool_config), to: Pooly.Supervisor, as: :start_link
end
