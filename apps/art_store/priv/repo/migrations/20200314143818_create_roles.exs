defmodule ArtStore.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :role_name, :string, null: false

      timestamps()
    end

    create unique_index(:roles, [:role_name])
  end
end
