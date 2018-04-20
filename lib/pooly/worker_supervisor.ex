defmodule Pooly.WorkerSupervisor do
  use DynamicSupervisor

  @name __MODULE__
  @opts [
    strategy: :one_for_one,
    max_restarts: 5,
    max_seconds: 5
  ]

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: @name)
  end

  def init(opts) do
    DynamicSupervisor.init(@opts ++ opts)
  end
end
