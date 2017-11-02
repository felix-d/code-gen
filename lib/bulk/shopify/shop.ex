defmodule Bulk.Shopify.Shop do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bulk.Shopify.Shop

  schema "shops" do
    field :name, :string
    field :shopify_token, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(%Shop{} = shop, attrs) do
    shop
    |> cast(attrs, [:name, :shopify_token, :token])
    |> validate_required([:name, :shopify_token, :token])
  end
end
