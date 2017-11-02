defmodule Bulk.Auth do
  import Ecto.Query, warn: false
  alias Bulk.Repo
  alias Bulk.Shopify.Shop

  def list_shop do
    Repo.all(Shop)
  end

  def get_shop!(id), do: Repo.get!(Shop, id)
  def get_shop_by_name(name), do: Repo.get_by(Shop, name: name)
  def get_shop_by_name!(name), do: Repo.get_by!(Shop, name: name)
  def get_shop_by_token!(token), do: Repo.get_by!(Shop, token: token)

  def create_shop(attrs \\ %{}) do
    %Shop{}
    |> Shop.changeset(attrs)
    |> Repo.insert()
  end

  def update_shop(%Shop{} = shop, attrs) do
    shop
    |> Shop.changeset(attrs)
    |> Repo.update()
  end

  def delete_shop(%Shop{} = shop) do
    Repo.delete(shop)
  end

  def change_shop(%Shop{} = shop) do
    Shop.changeset(shop, %{})
  end
end
