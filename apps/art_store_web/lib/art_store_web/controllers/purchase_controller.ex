defmodule ArtStoreWeb.PurchaseController do
  use ArtStoreWeb, :controller

  alias ArtStore.Repo
  alias ArtStore.Products
  alias ArtStore.Purchases
  alias ArtStore.Purchases.{Address, Customer}

  require Logger

  def receipt(conn, params) do
    customer = params["customer_id"]
      |> Purchases.get_customer!()
      |> Repo.preload(:product)
    product = customer.product
    render(conn, "receipt.html", customer: customer, product: product)
  end

  def create_a_checkout_session(conn, params) do
    params = %{
      cancel_url: "https://stripe.com",
      payment_method_types: ["card"],
      success_url: "https://example.com/success?session_id={CHECKOUT_SESSION_ID}",
      line_items: [%{
        name: "Cucumber from Roger's Farm",
        description: "Comfortable cotton t-shirt",
        images: ["https://res.cloudinary.com/gueloremanuel-com/image/upload/v1583733756/f3ijq5traywdeghbvgci.jpg"],
        amount: 200,
        currency: "cad",
        quantity: 10,
      }],
    }

    case Stripe.Session.create(params) do
      {:ok, res} ->
        Logger.warn("res: #{inspect(res)}")
        conn
        |> put_flash(:error, "Worked")
      {_,err_res} ->
        Logger.warn("error_res: #{inspect(err_res)}")
        conn
        |> put_flash(:error, "We couldn't charge your card")
    end
  end

  def create(conn, params) do
    # product = Products.get_product!(params["id"])

    # customer =
    #   params
    #   |> customer_changeset()
    #   |> Ecto.changeset.put_assoc(:product, product)
    #   |> Ecto.changeset.put_assoc(:ship_address, addr_changeset(params))
    #   |> Repo.insert!()

    # case Purchases.charge_customer(customer, product.price) do
    #   {:ok, _charge} ->
    #     #show the receipt to the customer, just email it to them
    #     conn
    #   {:error, _msg} ->
    #     # Need to track errors somehow
    #     conn
    #     |> put_flash(:error, "We couldn't charge your card")
    # end
  end

  defp addr_changeset(attrs) do
    address_attrs = %{
      "city" => attrs["StripeShippingAddressCity"],
      "country" => attrs["StripeShippingAddressCountry"],
      "line" => attrs["StripeShippingAddressLine1"],
      "name" => attrs["StripeShippingName"],
      "province" => attrs["StripeShippingProvince"],
      "postal_code" => attrs["StripeShippingPostalCode"]
    }

    Address.changeset(%Address{}, address_attrs)
  end

  defp customer_changeset(attrs) do
    customer_attrs = %{
      "email" => attrs["stripeEmail"],
      "stripe_customer_id" => Purchases.create_stripe_customer(attrs["stripeEmail"],
                                                               attrs["stripeToken"])
    }
    Customer.changeset(%Customer{}, attrs)
  end

end
