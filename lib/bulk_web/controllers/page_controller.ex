defmodule BulkWeb.PageController do
  use BulkWeb, :controller
  alias Bulk.Shopify.Client
  alias Bulk.Shopify.PriceRule

  def install(conn, %{"shop" => shop}) do
    redirect conn, external: Bulk.Auth.InstallationService.install_url(shop)
  end

  def auth(conn, params) do
    case Bulk.Auth.AuthService.authenticate(params) do
      :ok -> conn |> redirect(external: "https://www.shopify.com/admin/apps/#{api_client_id()}")
      {:error, digest} -> conn |> put_status(403) |> text("Authentication failed. Digest provided was: #{digest}")
    end
  end

  def index(conn, %{"shop" => shop, "id" => id} = params) do
    case Bulk.Auth.AuthService.authorize(params) do
      :ok ->
        shop = Bulk.Auth.get_shop_by_name!(shop)

        {:ok, client} = Client.start_link(shop.name, token: shop.token)
        title = PriceRule.get(client, id) |> PriceRule.title

        render conn, "index.html", shop: shop, title: title, api_client_id: api_client_id(), id: id
      {:error, digest} -> conn |> put_status(403) |> text("Authentication failed. Digest provided was: #{digest}")
    end
  end

  def index(conn, %{"shop" => shop} = params) do
    case Bulk.Auth.AuthService.authorize(params) do
      :ok ->
        shop = Bulk.Auth.get_shop_by_name(shop)
        render conn, "index.html", shop: shop, title: nil, api_client_id: api_client_id(), id: nil
      {:error, digest} -> conn |> put_status(403) |> text("Authentication failed. Digest provided was: #{digest}")
    end
  end

  def index(conn, _params) do
    conn
    |> redirect(to: "/info")
  end

  def info(conn, _params) do
    conn
    |> render("info.html")
  end

  defp api_client_id do
    Application.get_env(:bulk, :api_client_id)
  end
end
