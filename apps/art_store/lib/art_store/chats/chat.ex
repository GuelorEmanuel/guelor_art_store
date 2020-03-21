defmodule ArtStore.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :subject, :string
    field :is_group_chat, :boolean, default: true


    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:subject, :is_group_chat])
    |> validate_required([:subject])
  end
end
