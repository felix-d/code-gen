defmodule Bulk.Shopify.Client do
  use Agent
  require Logger

  def start_link(shop, id) do
    url = "https://#{shop.name}/admin/price_rules/#{id}"
    Agent.start_link(fn -> {url, shop.shopify_token} end)
  end

  def get(pid, path) do
    Agent.get(pid, fn {url, token} ->
      response = HTTPoison.get!("#{url}#{path}", headers(token))
      log_response(response)
      Poison.decode!(response.body)
    end)
  end

  def post(pid, path, params) do
    Agent.get(pid, fn {url, token} ->
      response = HTTPoison.post!("#{url}#{path}", Poison.encode!(params), headers(token))
      log_response(response)
      Poison.decode!(response.body)
    end)
  end

  defp log_response(response) do
    resp = case response do
      {:ok, resp} -> resp
      resp -> resp
    end

    "#{inspect(Poison.decode!(resp.body))}" |> Logger.debug
  end

  defp headers(token) do
    [
      {"Content-Type", "application/json"},
      {"X-Shopify-Access-Token", token},
    ]
  end
end
