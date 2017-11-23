defmodule Bulk.Shopify.PriceRule do
  use Agent
  alias Bulk.Shopify.Client

  def start_link(client_pid, id) do
    Agent.start_link(fn ->
      price_rule = Client.get(client_pid, "/admin/price_rules/#{id}.json") |> Map.get("price_rule")
      price_rule
    end)
  end

  def title(pid) do
    Agent.get(pid, fn price_rule ->
      price_rule |> Map.get("title")
    end)
  end

  def usage_limit(pid) do
    Agent.get(pid, fn price_rule ->
      price_rule |> Map.get("usage_limit")
    end)
  end
end
