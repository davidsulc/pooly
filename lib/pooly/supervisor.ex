defmodule Pooly.Supervisor do
  use Supervisor

  def start_link(pool_config) do
    IO.puts("Supervisor start_link")
    Supervisor.start_link(__MODULE__, pool_config)
  end

  def init(pool_config) do
    IO.puts("Supervisor init")
    children = [
      {Pooly.Server, [self(), pool_config]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
