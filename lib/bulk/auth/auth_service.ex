defmodule Bulk.Auth.AuthService do
  alias Bulk.Auth

  def authenticate(%{"shop" => shop, "code" => code} = params) do
    case authorize(params) do
      :ok ->
        update_shop_token(shop, code)
        :ok
      {:error, digest} -> {:error, digest}
    end
  end


  def authorize(%{"hmac" => hmac} = params) do
    query = params
            |> Map.delete("hmac")
            |> Map.delete("path")
            |> Enum.into([])
            |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
            |> Enum.map(fn {key, val} -> "#{key}=#{val}" end)
            |> Enum.join("&")
            |> URI.encode
    digest = :crypto.hmac(:sha256, api_client_secret(), query) |> Base.encode16(case: :lower)

    if SecureCompare.compare(digest, hmac) do
      :ok
    else
      {:error, digest}
    end
  end

  def authorize(_params) do
    if Application.get_env(:bulk, :skip_auth) do
      :ok
    else
      {:error, nil}
    end
  end

  defp update_shop_token(shop_name, code) do
    shopify_token = get_token(shop_name, code)

    case Auth.get_shop_by_name(shop_name) do
      nil -> Auth.create_shop(%{name: shop_name, shopify_token: shopify_token, token: generate_token(shop_name)})
      shop -> Auth.update_shop(shop, %{shopify_token: shopify_token})
    end
  end

  defp generate_token(shop) do
    :crypto.hmac(:sha256, token_secret(), shop) |> Base.encode16(case: :lower)
  end

  defp get_token(shop, code) do
    {:ok, client} = Bulk.Shopify.Client.start_link(shop)

    payload = %{
      client_id: api_client_id(),
      client_secret: api_client_secret(),
      code: code,
    }

    Bulk.Shopify.Client.post(client, "/admin/oauth/access_token", payload)
    |> Map.get("access_token")
  end

  defp api_client_secret do
    Application.get_env(:bulk, :api_client_secret)
  end

  defp api_client_id do
    Application.get_env(:bulk, :api_client_id)
  end

  defp token_secret do
    Application.get_env(:bulk, :token_secret)
  end
end
