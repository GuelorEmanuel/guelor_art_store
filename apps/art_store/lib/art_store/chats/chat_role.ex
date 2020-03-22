defmodule ArtStore.Chats.ChatRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chatroles" do
    field :user_id, :id
    field :chat_id, :id
    field :role_id, :id

    timestamps()
  end

  @doc false
  def changeset(chat_role, attrs) do
    chat_role
    |> cast(attrs, [])
    |> validate_required([])
  end
end
