defmodule Bulk.Creation.ActivitySupervisor do
  use Supervisor
  alias Bulk.Creation
  alias Bulk.Shopify.Shop

  @name __MODULE__

  def start_link do
    Supervisor.start_link(@name, nil, name: @name)
  end

  def init(_arg) do
    Supervisor.init([], strategy: :one_for_one)
  end

  def connect(id, socket) do
    case Creation.NotifierStore.get(id) do
      nil -> nil
      notifier -> Creation.Notifier.progress(notifier, socket)
    end
  end

  def generate_codes(%Shop{} = shop, count, id, prefix) do
    Creation.Task.start(shop, count, id, prefix)
  end
end
