defmodule ArtStore.Repo.Migrations.CreateChatroles do
  use Ecto.Migration

  def change do
    create table(:chatroles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :chat_id, references(:chats, on_delete: :delete_all), null: false
      add :role_id, references(:roles, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:chatroles, [:user_id])
    create index(:chatroles, [:chat_id])
    create index(:chatroles, [:role_id])
  end
end
