defmodule Pooly.Server do
  use GenServer

  @name __MODULE__
  @pool_config_keys [:sup, :size, :worker_sup_mod, :worker_spec]

  defmodule State do
    defstruct [:sup, :size, :worker_sup_mod, :worker_sup, :worker_spec, :monitors, workers: []]
  end

  def start_link([_sup, _pool_config] = opts) do
    IO.puts "in Server start_link"
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def init([sup, pool_config]) when is_pid(sup) do
    IO.puts "in Server init"
    monitors = :ets.new(:monitors, [:private])
    state = struct(State, pool_config |> sanitize())
    state = %{state | sup: sup, monitors: monitors}

    send(self(), :start_worker_supervisor)
    {:ok, state}
  end

  def handle_info(:start_worker_supervisor, %{sup: sup, worker_sup_mod: module, worker_spec: worker_spec, size: size} = state) do
    IO.puts "start worker supervisor request"
    {:ok, worker_sup} = Supervisor.start_child(sup, {module, [restart: :temporary]})
    workers = prepopulate(size, {worker_sup, worker_spec})
    {:noreply, %{state | worker_sup: worker_sup, workers: workers}}
  end

  def handle_info(msg, state) do
    IO.puts "Server received: #{msg}"
    {:noreply, state}
  end

  defp sanitize(config) do
    config
    |> Enum.filter(fn {k, _} -> Enum.member?(@pool_config_keys, k) end)
  end

  defp prepopulate(size, sup_args), do: prepopulate(size, sup_args, [])

  defp prepopulate(size, _sup_args, workers) when size < 1, do: workers

  defp prepopulate(size, sup_args, workers) do
    prepopulate(size - 1, sup_args, [new_worker(sup_args) | workers])
  end

  defp new_worker({sup, worker_spec}) do
    {:ok, worker} = DynamicSupervisor.start_child(sup, worker_spec)
    worker
  end
end
