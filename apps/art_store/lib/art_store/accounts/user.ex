defmodule ArtStore.Accounts.User do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias ArtStore.Accounts.{Credential, UserRole}
  alias ArtStore.Chats.{Message, Participant, ChatRole}

  schema "users" do
    field :username, :string
    field :verified, :boolean, default: false
    field :name, :string
    field :first_name, :string, virtual: true
    field :last_name, :string, virtual: true
    has_one :credential, Credential
    has_many :message, Message
    has_many :participant, Participant
    has_one :userroles, UserRole
    has_many :chat_role, ChatRole

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :username, :verified])
    |> build_full_name()
    |> validate_required([:first_name, :last_name, :username, :verified])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 4, max: 50)
    |> validate_length(:first_name, min: 1, max: 150)
    |> validate_length(:last_name, min: 1, max: 150)
  end

  defp build_full_name(changeset) do
    first_name = get_field(changeset, :first_name)
    last_name = get_field(changeset, :last_name)
    put_change(changeset, :name, "#{first_name} #{last_name}")
  end
end
