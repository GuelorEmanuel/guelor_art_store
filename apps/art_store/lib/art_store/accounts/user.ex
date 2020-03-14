defmodule ArtStore.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ArtStore.Accounts.Credential

  schema "users" do
    field :username, :string
    field :verified, :boolean, default: false
    field :name, :string
    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :verified])
    |> validate_required([:name, :username, :verified])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 4, max: 50)
    |> validate_length(:name, max: 150)
  end
end
