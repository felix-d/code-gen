defmodule Bulk.Auth.InstallationService do
  @scopes "write_price_rules,read_price_rules"

  def install_url(shop) do
    "https://#{shop}/admin/oauth/authorize?" <>
      "client_id=#{api_client_id()}&" <>
      "scope=#{@scopes}&" <>
      "redirect_uri=#{scheme()}://#{host()}#{if port() != 443 && port() != 80, do: ":#{port()}"}/auth"
  end

  defp api_client_id do
    Application.get_env(:bulk, :api_client_id)
  end

  defp host do
    Application.get_env(:bulk, BulkWeb.Endpoint)[:url][:host]
  end

  defp port do
    Application.get_env(:bulk, BulkWeb.Endpoint)[:url][:port]
  end

  defp scheme do
    Application.get_env(:bulk, BulkWeb.Endpoint)[:url][:scheme]
  end
end
