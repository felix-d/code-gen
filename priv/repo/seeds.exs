# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
Bulk.Repo.insert!(%Bulk.Shopify.Shop{
  name: "testshop.com",
  token: "c2ZzZHNkZnNkZnNmc2QwOS1mMDlnZGY5ZGZnZGZn",
  shopify_token: "OThiMGRmOTg4Zmc4aDhkZjBnaDhmZzhoZmRn"
})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
