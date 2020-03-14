defmodule ArtStoreWeb.ProductLive.Index do
  use Phoenix.LiveView

  alias ArtStoreWeb.ProductView

  def mount(_params, %{"product" => product}, socket) do
    prod_quantity =
      if (product.quantity >= 1), do: 1, else: 0

    socket =
      socket
      |> assign(
           quantity: prod_quantity,
           product: product,
           checkout_session_id: "",
           stripe_pk: "#{Application.get_env(:art_store_web, ArtStoreWeb.Endpoint)[:stripe_pk]}"
      )
    temp_product = %{"name" => product.name,
                     "detail" => product.detail,
                     "url" => product.url,
                     "price" => product.price,
                     "id" => product.id,
                     "quantity" => prod_quantity}

    case create_stripe_session_helper(temp_product) do
      {:ok, res} ->
        {:ok, assign(socket, :checkout_session_id, res.id)}
      {_, _err_res} ->
        {:ok, assign(socket, :checkout_session_err, "This item isn't available at the moment")}
    end
  end

  def render(assigns) do
    ProductView.render("show.html", assigns)
  end

  def handle_event("set_quantity", values, socket) do
    case create_stripe_session_helper(values) do
      {:ok, res} ->
        {:noreply, assign(socket, :checkout_session_id, res.id)}
      {_, _err_res} ->
        {:noreply, assign(socket, :checkout_session_err, "This item isn't available at the moment")}
    end
  end

  defp create_stripe_session_helper(%{"myvar1" => name,
                                      "myvar2" => detail,
                                      "myvar3" => url,
                                      "myvar4" => price,
                                      "myvar5" => id,
                                      "value" => quantity}) do
    create_stripe_session(name, detail, url, price, id, quantity)
  end
  defp create_stripe_session_helper(%{"name" => name,
                                      "detail" => detail,
                                      "url" => url,
                                      "price" => price,
                                      "id" => id,
                                      "quantity" => quantity}) do
    create_stripe_session(name, detail, url, price, id, quantity)
  end

  defp create_stripe_session(name, detail, url, price, id, quantity) do
    params = %{
      cancel_url: "#{Application.get_env(:art_store_web, ArtStoreWeb.Endpoint)[:cancel_url]}#{id}",
      payment_method_types: ["card"],
      success_url: "#{Application.get_env(:art_store_web, ArtStoreWeb.Endpoint)[:success_url]}{CHECKOUT_SESSION_ID}",
      line_items: [%{
        name: "#{name}",
        description: "#{detail}",
        images: ["#{url}"],
        amount: price,
        currency: "cad",
        quantity: quantity,
      }],
    }

    Stripe.Session.create(params)
  end
end
