defmodule ArtStore.Accounts.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias ArtStore.Accounts.{User, Role}

  schema "userroles" do
    belongs_to :user, User
    belongs_to :role, Role

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [])
    |> validate_required([])
  end
end
