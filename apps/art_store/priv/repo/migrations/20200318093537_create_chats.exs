defmodule ArtStore.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :subject, :string, null: false
      add :is_group_chat, :boolean, default: true, null: false

      timestamps()
    end
  end
end
