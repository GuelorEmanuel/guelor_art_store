defmodule ArtStore.PurchasesTest do
  use ArtStore.DataCase

  alias ArtStore.Purchases
  alias ArtStore.Products

  def unload_relations(obj, to_remove \\ nil) do
    assocs =
      if to_remove == nil,
        do: obj.__struct__.__schema__(:associations),
      else: Enum.filter(obj.__struct__.__schema__(:associations), &(&1 in to_remove))
      
      Enum.reduce(assocs, obj, fn assoc, obj ->
        assoc_meta = obj.__struct__.__schema__(:association, assoc)
        
        Map.put(obj, assoc, %Ecto.Association.NotLoaded{
          __field__: assoc,
          __owner__: assoc_meta.owner,
          __cardinality__: assoc_meta.cardinality
        })
      end)
  end

  describe "customers" do
    alias ArtStore.Purchases.Customer
    
    @valid_product_attrs %{detail: "some  detail", price: 42, quantity: 42, name: "some name", url: "some url"}
    @valid_attrs %{email: "some email", stripe_customer_id: "some stripe_customer_id"}
    @update_attrs %{email: "some updated email", stripe_customer_id: "some updated stripe_customer_id"}
    @invalid_attrs %{email: nil, stripe_customer_id: nil}

    def customer_fixture(attrs \\ %{}) do
      {:ok, product} = 
        Products.create_product(@valid_product_attrs)
      
      {:ok, customer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Purchases.create_customer(product)

      customer
    end

    test "list_customers/0 returns all customers" do
      customer = 
        customer_fixture()
        |> unload_relations()

      assert Purchases.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = 
        customer_fixture()
        |> unload_relations()

      assert Purchases.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      {:ok, product} = 
        Products.create_product(@valid_product_attrs)

      assert {:ok, %Customer{} = customer} = Purchases.create_customer(@valid_attrs, product)
      assert customer.email == "some email"
      assert customer.stripe_customer_id == "some stripe_customer_id"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      {:ok, product} = 
        Products.create_product(@valid_product_attrs)
        
      assert {:error, %Ecto.Changeset{}} = Purchases.create_customer(@invalid_attrs, product)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = customer} = Purchases.update_customer(customer, @update_attrs)
      assert customer.email == "some updated email"
      assert customer.stripe_customer_id == "some updated stripe_customer_id"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = 
        customer_fixture()
        |> unload_relations()

      assert {:error, %Ecto.Changeset{}} = Purchases.update_customer(customer, @invalid_attrs)
      assert customer == Purchases.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Purchases.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Purchases.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Purchases.change_customer(customer)
    end
  end

  describe "addresses" do
    alias ArtStore.Purchases.Address

    @valid_customer_attrs %{email: "some email", stripe_customer_id: "some stripe_customer_id"}
    @valid_attrs %{city: "some city", country: "some country", line: "some line", name: "some name", province: "some province", postal_code: "some postal_code"}
    @update_attrs %{city: "some updated city", country: "some updated country", line: "some updated line", name: "some updated name", province: "some updated province", postal_code: "some updated postal_code"}
    @invalid_attrs %{city: nil, country: nil, line: nil, name: nil, province: nil, postal_code: nil}

    def address_fixture(attrs \\ %{}) do
      {:ok, product} = 
        Products.create_product(@valid_product_attrs)
      
      {:ok, customer} =
        @valid_customer_attrs
        |> Purchases.create_customer(product)

      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Purchases.create_address(customer)

      address
    end

    test "list_addresses/0 returns all addresses" do
      address = 
        address_fixture()
        |> unload_relations()

      assert Purchases.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = 
        address_fixture()
        |> unload_relations()

      assert Purchases.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      {:ok, product} = 
        Products.create_product(@valid_product_attrs)
      
      {:ok, customer} =
        @valid_customer_attrs
        |> Purchases.create_customer(product)

      assert {:ok, %Address{} = address} = Purchases.create_address(@valid_attrs, customer)
      assert address.city == "some city"
      assert address.country == "some country"
      assert address.line == "some line"
      assert address.name == "some name"
      assert address.province == "some province"
      assert address.postal_code == "some postal_code"
    end

    test "create_address/1 with invalid data returns error changeset" do
      {:ok, product} = 
        Products.create_product(@valid_product_attrs)
    
      {:ok, customer} =
        @valid_customer_attrs
        |> Purchases.create_customer(product)

      assert {:error, %Ecto.Changeset{}} = Purchases.create_address(@invalid_attrs, customer)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, %Address{} = address} = Purchases.update_address(address, @update_attrs)
      assert address.city == "some updated city"
      assert address.country == "some updated country"
      assert address.line == "some updated line"
      assert address.name == "some updated name"
      assert address.province == "some updated province"
      assert address.postal_code == "some updated postal_code"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = 
        address_fixture()
        |> unload_relations()
        
      assert {:error, %Ecto.Changeset{}} = Purchases.update_address(address, @invalid_attrs)
      assert address == Purchases.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Purchases.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Purchases.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Purchases.change_address(address)
    end
  end
end
