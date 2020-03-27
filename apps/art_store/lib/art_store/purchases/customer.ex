defmodule ArtStore.Purchases.Customer do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias ArtStore.Products.Product
  alias ArtStore.Purchases.Address

  schema "customers" do
    field :email, :string
    field :stripe_customer_id, :string
    has_one :address, Address
    belongs_to :product, Product

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email, :stripe_customer_id])
    |> validate_required([:email, :stripe_customer_id])
  end
end
