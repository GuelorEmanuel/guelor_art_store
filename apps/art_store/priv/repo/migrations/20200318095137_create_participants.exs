defmodule ArtStore.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :last_read, :naive_datetime
      add :chat_id, references(:chats, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:participants, [:chat_id])
    create index(:participants, [:user_id])
  end
end
