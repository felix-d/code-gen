defmodule Bulk.Shopify.PriceRule do
  use Agent
  alias Bulk.Shopify.Client

  def get(client_pid, id) do
    Client.get(client_pid, "/admin/price_rules/#{id}.json") |> Map.get("price_rule")
  end

  def title(price_rule) do
    price_rule |> Map.get("title")
  end

  def usage_limit(price_rule) do
    price_rule |> Map.get("usage_limit")
  end
end
