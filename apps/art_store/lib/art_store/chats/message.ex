defmodule ArtStore.Chats.Message do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

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
    |> cast(attrs, [:content, :user_id, :chat_id])
    |> validate_required([:content])
  end
end
