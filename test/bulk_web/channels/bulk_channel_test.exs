defmodule BulkWeb.BulkChannelTest do
  use BulkWeb.ChannelCase
  import Mock
  alias BulkWeb.BulkChannel
  alias Bulk.Auth
  alias Bulk.Creation

  @endpoint BulkWeb.Endpoint
  @valid_attrs %{
    name: "some-shop.com",
    shopify_token: "some shopify_token",
    token: "some token",
  }

  defmodule MockResponse do
    defstruct body: nil
  end

  def shop_fixture(attrs \\ %{}) do
    {:ok, shop} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Auth.create_shop()

    shop
  end

  test "join the channel when there is no running task" do
    shop = shop_fixture()
    {:ok, _, _socket} =
      socket("user_socket:#{shop.token}", %{shop: shop})
      |> subscribe_and_join(BulkChannel, "bulk:123", %{})
  end

  test "join the channel when there is a running task" do
    shop = shop_fixture()

    Creation.StatusManager.task_started(id: "123", code_count: 100)

    {:ok, _, _socket} =
      socket("user_socket:#{shop.token}", %{shop: shop})
      |> subscribe_and_join(BulkChannel, "bulk:123", %{})

    assert_push "progress", %{id: "123", code_count: 100, progress: 0}, 100
  end

  test "run a code generation" do
    shop = shop_fixture()

    {:ok, _, socket} =
      socket("user_socket:#{shop.token}", %{shop: shop})
      |> subscribe_and_join(BulkChannel, "bulk:123", %{})

    creation_result = %MockResponse{body: Poison.encode! %{
      "discount_code_creation" => %{
        "status" => "pending",
        "id" => 66,
      }
    }}

    creation_status = %MockResponse{body: Poison.encode! %{
      "discount_code_creation" => %{
        "status" => "completed",
      }
    }}

    with_mock HTTPoison, [
      post!: fn ("https://some-shop.com/admin/price_rules/123/batch.json", _, _) -> creation_result end,
      get!: fn ("https://some-shop.com/admin/price_rules/123/batch/66.json", _) -> creation_status end,
    ] do
      push(socket, "generate", %{
        "count" => 100,
        "id" => "123",
        "token" => shop.token,
        "prefix" => "abc",
      })

      assert_broadcast("progress", %{
        code_count: 100,
        id: "123",
        progress: 0,
      }, 1000)

      assert_broadcast("progress", %{
        code_count: 100,
        id: "123",
        progress: 0.5,
      }, 1000)

      assert_broadcast("progress", %{
        code_count: 100,
        id: "123",
        progress: 1.0,
      }, 1000)
    end
  end
end
