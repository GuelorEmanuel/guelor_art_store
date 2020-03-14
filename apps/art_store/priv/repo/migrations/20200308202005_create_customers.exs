defmodule ArtStore.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :email, :string, null: false
      add :stripe_customer_id, :string, null: false
      add :product_id, references(:products, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:customers, [:product_id])
  end
end
