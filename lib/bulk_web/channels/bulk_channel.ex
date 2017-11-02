defmodule BulkWeb.BulkChannel do
  use Phoenix.Channel
  alias Bulk.Auth
  alias Bulk.Creation

  def join("bulk:" <> id, _params, socket) do
    send(self(), {:after_join, id})
    {:ok, socket}
  end

  def handle_info({:after_join, id}, socket) do
    connect(id, socket)
    {:noreply, socket}
  end

  def handle_in("generate", %{"count" => count, "id" => id, "token" => token, "prefix" => prefix}, socket) do
    shop = Auth.get_shop_by_token!(token)
    generate_codes(shop, count, id, prefix)
    {:noreply, socket}
  end

  defp connect(id, socket) do
    case Creation.NotifierStore.get(id) do
      nil -> nil
      notifier -> Creation.Notifier.progress(notifier, socket)
    end
  end

  defp generate_codes(shop, count, id, prefix) do
    Creation.Task.start(shop, count, id, prefix)
  end
end
