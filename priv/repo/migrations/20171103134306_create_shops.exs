defmodule Bulk.Repo.Migrations.CreateShops do
  use Ecto.Migration

  def change do
    create table(:shops) do
      add :name, :string
      add :shopify_token, :string
      add :token, :string


      timestamps()
    end

    create index(:shops, [:name], unique: true)
    create index(:shops, [:token])
  end
end
