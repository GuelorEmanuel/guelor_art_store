defmodule ArtStore.Accounts.Role do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias ArtStore.Accounts.UserRole
  alias ArtStore.Chats.ChatRole


  schema "roles" do
    field :role_name, :string
    has_many :user_role, UserRole
    has_many :chat_role, ChatRole
    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:role_name])
    |> validate_required([:role_name])
    |> unique_constraint(:role_name)
  end
end
