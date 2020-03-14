defmodule ArtStore.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :detail, :string, null: false
      add :price, :bigint, null: false
      add :quantity, :integer, default: 1, null: false
      add :url, :text, null: false
      add :available, :boolean, default: true, null: false

      timestamps()
    end

  end
end
