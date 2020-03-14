defmodule ArtStore.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :verified, :boolean, default: false
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :verified])
    |> validate_required([:name, :username, :verified])
    |> unique_constraint(:username)
  end
end
