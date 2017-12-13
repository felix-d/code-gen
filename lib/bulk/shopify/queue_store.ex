defmodule Bulk.Shopify.QueueStore do
  def cache_name do
    :queue_store
  end

  def get(key) do
    case Cachex.get(cache_name(), key) do
      {:ok, nil} -> nil
      {:ok, queue} -> queue
      _ -> nil
    end
  end

  def set(key, queue) do
    Cachex.set(cache_name(), key, queue)
  end

  def touch(key) do
    Cachex.touch(cache_name(), key)
  end
end
