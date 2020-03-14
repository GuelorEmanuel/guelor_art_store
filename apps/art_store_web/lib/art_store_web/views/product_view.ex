defmodule ArtStoreWeb.ProductView do
  use ArtStoreWeb, :view
  use Number

  def cents_to_dollar(price) do
    price / 100 |> Number.Currency.number_to_currency()
  end
end
