defmodule Bulk.Shopify.Creation do
  alias Bulk.Shopify.Client

  def get(client_pid, id, creation_id) do
    Client.get(client_pid, "/admin/price_rules/#{id}/batch/#{creation_id}.json")
  end

  def create(client_pid, id, params) do
    Client.post(client_pid, "/admin/price_rules/#{id}/batch.json", params)
  end

  def status(creation) do
    creation
    |> Map.get("discount_code_creation")
    |> Map.get("status")
  end

  def id(creation) do
    creation
    |> Map.get("discount_code_creation")
    |> Map.get("id")
  end
end
