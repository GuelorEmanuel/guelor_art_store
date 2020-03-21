defmodule ArtStore.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ArtStore.Accounts.Credential
  alias ArtStore.Chats.{Chat, Message, Participant}

  schema "users" do
    field :username, :string
    field :verified, :boolean, default: false
    field :name, :string
    has_one :credential, Credential
    has_many :chat, Chat
    has_many :message, Message
    has_one :participant, Participant

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :verified])
    |> validate_required([:name, :username, :verified])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 4, max: 50)
    |> validate_length(:name, min: 1, max: 150)
  end
end
