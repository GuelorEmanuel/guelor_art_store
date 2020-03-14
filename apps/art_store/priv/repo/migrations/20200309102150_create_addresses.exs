defmodule ArtStore.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :name, :string, null: false
      add :line, :string, null: false
      add :city, :string, null: false
      add :province, :string, null: false
      add :postal_code, :string, null: false
      add :country, :string, null: false
      add :customer_id, references(:customers, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:addresses, [:customer_id])
  end
end
