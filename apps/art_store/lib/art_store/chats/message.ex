defmodule ArtStore.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias ArtStore.Accounts.User
  alias ArtStore.Chats.Chat

  schema "messages" do
    field :content, :string
    belongs_to :chat, Chat
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
