defmodule Bulk.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    queue_store_id = Bulk.Shopify.QueueStore.cache_name()

    children = [
      supervisor(BulkWeb.Endpoint, []),
      supervisor(Bulk.Repo, []),
      worker(Bulk.Creation.StatusManager, []),
      worker(Bulk.Creation.TaskManager, []),
      worker(Cachex, [queue_store_id, []], id: queue_store_id),
    ]

    opts = [strategy: :one_for_one, name: Bulk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    BulkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
