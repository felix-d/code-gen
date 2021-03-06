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

  def handle_in("generate", %{"codes" => codes, "id" => id, "token" => token}, socket) do
    shop = Auth.get_shop_by_token!(token)
    generate_codes(shop, codes, id)
    {:noreply, socket}
  end

  defp connect(id, socket) do
    case Creation.StatusManager.task_status(id) do
      nil -> nil
      status -> Phoenix.Channel.push(socket, "progress", status)
    end
  end

  defp generate_codes(shop, code_count, id, prefix) do
    Creation.TaskManager.start_task(shop, code_count, id, prefix)
  end

  defp generate_codes(shop, codes, id) do
    Creation.TaskManager.start_task(shop, codes, id )
  end
end
