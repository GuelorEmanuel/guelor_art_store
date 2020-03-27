defmodule ArtStore.Chats.Participant do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias ArtStore.Accounts.User
  alias ArtStore.Chats.Chat

  schema "participants" do
    field :last_read, :utc_datetime
    belongs_to :chat, Chat
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:last_read])
    |> validate_required([:last_read])
  end
end
