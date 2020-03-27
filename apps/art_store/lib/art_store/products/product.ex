defmodule ArtStore.Products.Product do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias ArtStore.Purchases.Customer

  schema "products" do
    field :detail, :string
    field :price, :integer
    field :quantity, :integer
    field :name, :string
    field :url, :string, size: 200
    field :available, :boolean, default: false
    has_many :customer, Customer

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :detail, :price, :quantity, :url, :available])
    |> validate_required([:name, :detail, :price, :quantity, :url])
  end
end
