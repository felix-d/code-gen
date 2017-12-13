defmodule Bulk.AuthTest do
  use Bulk.DataCase

  alias Bulk.Auth

  describe "shop" do
    alias Bulk.Shopify.Shop

    @valid_attrs %{
      name: "some-name.com",
      shopify_token: "some shopify_token",
      token: "some token",
    }
    @update_attrs %{
      name: "some-updated-name.com",
      shopify_token: "some updated shopify_token",
      token: "some updated token",
    }
    @invalid_attrs %{
      name: nil,
      shopify_token: nil,
      token: nil,
    }

    def shop_fixture(attrs \\ %{}) do
      {:ok, shop} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_shop()

      shop
    end

    test "list_shop/0 returns all shop" do
      shop = shop_fixture()
      assert Auth.list_shop() == [shop]
    end

    test "get_shop!/1 returns the shop with given id" do
      shop = shop_fixture()
      assert Auth.get_shop!(shop.id) == shop
    end

    test "get_shop_by_name!/1 returns the shop with a given name" do
      shop = shop_fixture()
      assert shop == Auth.get_shop_by_name!("some-name.com")
    end

    test "get_shop_by_name/1 returns the shop with a given name" do
      shop = shop_fixture()
      assert shop == Auth.get_shop_by_name("some-name.com")
    end

    test "get_shop_by_name/1 returns nil if the shop was not found" do
      refute Auth.get_shop_by_name("foobar")
    end

    test "get_shop_by_name!/1 raises if the name is the shop was not found" do
      assert_raise(Ecto.NoResultsError, fn ->
        Auth.get_shop_by_name!("foobar")
      end)
    end

    test "get_shop_by_token!/1 returns the shop with a given token" do
      shop = shop_fixture()
      assert shop == Auth.get_shop_by_token!(shop.token)
    end

    test "get_shop_by_token!/1 raises if the shop was not found" do
      assert_raise(Ecto.NoResultsError, fn ->
        Auth.get_shop_by_token!("foobar")
      end)
    end

    test "create_shop/1 with valid data creates a shop" do
      assert {:ok, %Shop{} = shop} = Auth.create_shop(@valid_attrs)
      assert shop.name == "some-name.com"
      assert shop.shopify_token == "some shopify_token"
    end

    test "create_shop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_shop(@invalid_attrs)
    end

    test "update_shop/2 with valid data updates the shop" do
      shop = shop_fixture()
      assert {:ok, shop} = Auth.update_shop(shop, @update_attrs)
      assert %Shop{} = shop
      assert shop.name == "some-updated-name.com"
      assert shop.shopify_token == "some updated shopify_token"
    end

    test "update_shop/2 with invalid data returns error changeset" do
      shop = shop_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_shop(shop, @invalid_attrs)
      assert shop == Auth.get_shop!(shop.id)
    end

    test "delete_shop/1 deletes the shop" do
      shop = shop_fixture()
      assert {:ok, %Shop{}} = Auth.delete_shop(shop)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_shop!(shop.id) end
    end

    test "change_shop/1 returns a shop changeset" do
      shop = shop_fixture()
      assert %Ecto.Changeset{} = Auth.change_shop(shop)
    end
  end
end
