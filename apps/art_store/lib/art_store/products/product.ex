defmodule ArtStore.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :detail, :string
    field :price, :integer
    field :quantity, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :detail, :price, :quantity])
    |> validate_required([:name, :detail, :price, :quantity])
  end
end
