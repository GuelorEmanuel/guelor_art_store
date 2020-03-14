defmodule ArtStore.Purchases.Address do
  use Ecto.Schema
  import Ecto.Changeset

  alias ArtStore.Purchases.Customer

  schema "addresses" do
    field :city, :string
    field :country, :string
    field :line, :string
    field :name, :string
    field :province, :string
    field :postal_code, :string
    belongs_to :customer, Customer

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:name, :line, :city, :province, :postal_code, :country])
    |> validate_required([:name, :line, :city, :province, :postal_code, :country])
  end
end
