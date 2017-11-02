defmodule BulkWeb.PageController do
  use BulkWeb, :controller
  alias Bulk.Shopify.Shop
  alias Bulk.Shopify.Client
  alias Bulk.Shopify.PriceRule
  require Logger
  require IEx

  def auth(conn, %{"shop" => _shop, "code" => _code, "hmac" => _hmac} = params) do
    case Bulk.Auth.AuthService.authenticate(params) do
      :ok -> conn |> redirect(external: "https://www.shopify.com/admin/apps/discount-code-generator")
      {:error, digest} -> conn |> put_status(403) |> text("Authentication failed. Digest provided was: #{digest}")
    end
  end

  def index(conn, %{"shop" => shop, "id" => id, "hmac" => _hmac} = params) do
    case Bulk.Auth.AuthService.authorize(params) do
      :ok ->
        %Shop{token: token} = shop = Bulk.Auth.get_shop_by_name!(shop)
        {:ok, client} = Client.start_link(shop, id)
        {:ok, price_rule} = PriceRule.start_link(client)
        render conn, "index.html", token: token, shop: shop, title: PriceRule.title(price_rule), usage_limit: PriceRule.usage_limit(price_rule)

      {:error, digest} -> conn |> put_status(403) |> text("Authentication failed. Digest provided was: #{digest}")
    end

  end

  def index(conn, %{"shop" => shop, "hmac" => _hmac} = params) do
    case Bulk.Auth.AuthService.authorize(params) do
      :ok ->
        %Shop{token: token} = shop = Bulk.Auth.get_shop_by_name!(shop)
        render conn, "index.html", token: token, shop: shop, title: nil, usage_limit: nil
      {:error, digest} -> conn |> put_status(403) |> text("Authentication failed. Digest provided was: #{digest}")
    end
  end

  def index(conn, %{"shop" => shop}) do
    redirect conn, external: Bulk.Auth.InstallationService.install_url(shop)
  end

  def index(conn, _params) do
    conn
    |> redirect(to: "/info")
  end

  def info(conn, _params) do
    conn
    |> render("info.html")
  end
end
