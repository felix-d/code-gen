defmodule Bulk.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    notifier_store_id = Bulk.Creation.NotifierStore.cache_name()
    queue_store_id = Bulk.Creation.QueueStore.cache_name()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BulkWeb.Endpoint, []),
      supervisor(Bulk.Repo, []),
      worker(Cachex, [notifier_store_id, []], id: notifier_store_id),
      worker(Cachex, [queue_store_id, []], id: queue_store_id),
      # Start your own worker by calling: Bulk.Worker.start_link(arg1, arg2, arg3)
      # worker(Bulk.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bulk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BulkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
