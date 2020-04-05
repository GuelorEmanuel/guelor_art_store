defmodule ArtStore.Chats.ChatRole do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias ArtStore.Accounts.{User, Role}
  alias ArtStore.Chats.Chat


  schema "chatroles" do
    belongs_to :user, User
    belongs_to :chat, Chat
    belongs_to :role, Role

    timestamps()
  end

  @doc false
  def changeset(chat_role, attrs) do
    chat_role
    |> cast(attrs, [:role_id])
    |> validate_required([])
  end
end
