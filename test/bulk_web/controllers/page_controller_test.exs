defmodule BulkWeb.PageControllerTest do
  alias Bulk.Repo
  alias Bulk.Shopify.Shop
  import Phoenix.Controller, only: [view_template: 1]
  import Mock
  alias Bulk.Auth
  use BulkWeb.ConnCase

  @valid_attrs %{
    name: "some-shop.com",
    shopify_token: "some shopify_token",
    token: "some token",
  }

  def shop_fixture(attrs \\ %{}) do
    {:ok, shop} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Auth.create_shop()

    shop
  end

  test "GET / with no params redirect to /info", %{conn: conn} do
    conn = get conn, "/"
    assert redirected_to(conn, 302) == "/info"
  end

  test "GET /info renders the info page", %{conn: conn} do
    conn = get conn, "/info"
    assert view_template(conn) == "info.html"
  end

  test "GET / with present shop param", %{conn: conn} do
    shop = shop_fixture()
    conn = get conn, "/?shop=#{shop.name}"
    %{id: nil, title: nil, shop: ^shop} = conn.assigns
    assert view_template(conn) == "index.html"
  end

  test "GET / with present shop and id param", %{conn: conn} do
    shop = shop_fixture()
    with_mock Bulk.Shopify.Client, [
      start_link: fn(_shop, _token) -> {:ok, nil} end,
      get: fn(_pid, "/admin/price_rules/1.json") -> %{"price_rule" => %{"title" => "foo"}} end,
    ] do
      conn = get conn, "/?shop=#{shop.name}&id=1"
      %{id: "1", title: "foo", shop: ^shop} = conn.assigns
      assert view_template(conn) == "index.html"
    end
  end

  test "GET /install with present shop param redirects to shopify", %{conn: conn} do
    conn = get conn, "/install?shop=my-new-shop.com"
    assert redirected_to(conn, 302) == "https://my-new-shop.com/admin/oauth/authorize?" <>
      "client_id=#{api_client_id()}&scope=write_price_rules,read_price_rules&" <>
      "redirect_uri=https://testhost/auth"
  end

  test "GET /auth creates an entry in the database for a new shop", %{conn: conn} do
    params = %{
      client_id: api_client_id(),
      client_secret: api_client_secret(),
      code: "ABC",
    }

    with_mock Bulk.Shopify.Client, [
      start_link: fn(_shop) -> {:ok, nil} end,
      post: fn(_pid, "/admin/oauth/access_token", ^params) -> %{"access_token" => "TOKEN"} end,
    ] do
      conn = get conn, "/auth?shop=my-new-shop.com&code=ABC"
      assert redirected_to(conn, 302) == "https://www.shopify.com/admin/apps/#{api_client_id()}"

      shop = Repo.get_by!(Shop, name: "my-new-shop.com")
      assert shop.shopify_token == "TOKEN"
      assert shop.token == :crypto.hmac(:sha256, token_secret(), shop.name) |> Base.encode16(case: :lower)
    end
  end

  test "GET /auth updates the token for an existing shop", %{conn: conn} do
    params = %{
      client_id: api_client_id(),
      client_secret: api_client_secret(),
      code: "ABC",
    }

    with_mock Bulk.Shopify.Client, [
      start_link: fn(_shop) -> {:ok, nil} end,
      post: fn(_pid, "/admin/oauth/access_token", ^params) -> %{"access_token" => "TOKEN"} end,
    ] do
      conn = get conn, "/auth?shop=some-shop.com&code=ABC"
      assert redirected_to(conn, 302) == "https://www.shopify.com/admin/apps/#{api_client_id()}"

      shop = Repo.get_by!(Shop, name: "some-shop.com")
      assert shop.shopify_token == "TOKEN"
    end
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
