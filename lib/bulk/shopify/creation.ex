defmodule Bulk.Shopify.Creation do
  alias Bulk.Shopify.Client

  def status(client_pid, id, creation_id) do
    Client.get(client_pid, "/admin/price_rules/#{id}/batch/#{creation_id}.json")
    |> Map.get("discount_code_creation")
    |> Map.get("status")
  end

  def id(client_pid, id, params) do
    Client.post(client_pid, "/admin/price_rules/#{id}/batch.json", params)
    |> Map.get("discount_code_creation")
    |> Map.get("id")
  end
end
