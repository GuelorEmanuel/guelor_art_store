defmodule ArtStore.Purchases do
  @moduledoc """
  The Purchases context.
  """

  import Ecto.Query, warn: false
  alias ArtStore.Repo

  alias ArtStore.Purchases.Customer
  alias ArtStore.Purchases.Address


  def charge_customer(customer, amount) do
    source =
      customer.stripe_customer_id
      |> get_stripe_customer()
      |> get_in([:default_source])

    opts = [customer: customer.stripe_customer_id, source: source]
    case Stripe.Charges.create(amount, opts) do
      {:ok, charge} ->
        {:ok, charge}
      {:error, %{"error" => %{"message" => msg}}} ->
        {:error, msg}
    end
  end

  def get_stripe_customer(customer_id) do
    case Stripe.Customers.get(customer_id) do
      {:ok, customer} ->
        customer
      {:error, _} ->
        nil
    end
  end
  ## Passing in the source when we create a customer will create a default payment
  ## source in Stripe with the card they entered. This gives us some flexibility,
  ## so if we wanted to wait until the order ships to charge the card we could do that.
  def create_stripe_customer(email, token) do
    case Stripe.Customer.create(email: email, source: token) do
      {:ok, %{id: stripe_customer_id}} -> stripe_customer_id
      {:error, _} -> nil
    end
  end

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list_customers()
      [%Customer{}, ...]

  """
  def list_customers do
    Repo.all(Customer)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value}, %Product{})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value}, %Product{})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}, product) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:product, product)
    |> Ecto.Changeset.cast_assoc(:address, with: &Address.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{source: %Customer{}}

  """
  def change_customer(%Customer{} = customer) do
    Customer.changeset(customer, %{})
  end


  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses()
      [%Address{}, ...]

  """
  def list_addresses do
    Repo.all(Address)
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

      iex> get_address!(123)
      %Address{}

      iex> get_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_address!(id), do: Repo.get!(Address, id)

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%{field: value}, %Customer{})
      {:ok, %Address{}}

      iex> create_address(%{field: bad_value}, %Customer{})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(attrs \\ %{}, customer) do
    %Address{}
    |> Address.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:customer, customer)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples

      iex> update_address(address, %{field: new_value})
      {:ok, %Address{}}

      iex> update_address(address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a address.

  ## Examples

      iex> delete_address(address)
      {:ok, %Address{}}

      iex> delete_address(address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

      iex> change_address(address)
      %Ecto.Changeset{source: %Address{}}

  """
  def change_address(%Address{} = address) do
    Address.changeset(address, %{})
  end
end
