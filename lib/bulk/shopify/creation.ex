defmodule Bulk.Shopify.Creation do
  alias Bulk.Shopify.Client
  def status(client_pid, creation_id) do
    Client.get(client_pid, "/batch/#{creation_id}.json")
    |> Map.get("discount_code_creation")
    |> Map.get("status")
  end

  def id(client_id, params) do
    Client.post(client_id, "/batch.json", params)
    |> Map.get("discount_code_creation")
    |> Map.get("id")
  end
end
