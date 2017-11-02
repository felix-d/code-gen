defmodule Bulk.Creation.NotifierStore do
  def cache_name do
    :notifier_store
  end

  def get(key) do
    case Cachex.get(cache_name(), key) do
      {:ok, nil} -> nil
      {:ok, notifier} -> notifier
      _ -> nil
    end
  end

  def set(key, notifier) do
    Cachex.set(cache_name(), key, notifier)
  end

  def del(key) do
    Cachex.del(cache_name(), key)
  end
end
