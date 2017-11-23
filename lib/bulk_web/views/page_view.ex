defmodule BulkWeb.PageView do
  use BulkWeb, :view
  alias Bulk.Shopify.Shop

  def shop_name(%{shop: %Shop{} = shop}), do: shop.name
  def shop_name(_params), do: nil

  def shop_token(%{shop: %Shop{} = shop}), do: shop.token
  def shop_token(_params), do: nil
end
