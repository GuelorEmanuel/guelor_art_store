defmodule ArtStoreWeb.ProductController do
  use ArtStoreWeb, :controller

  alias ArtStore.Products
  alias ArtStore.Products.Product
  alias Phoenix.LiveView
  alias ArtStoreWeb.ProductLive.Index

  require Logger

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, "index.html", products: products)
  end

  def new(conn, _params) do
    changeset = Products.change_product(%Product{})
    render(conn, "new.html", changeset: changeset)
  end

  defp upload_image_to_cloudinary(path) do
    Logger.warn("path: #{path}")
    case Cloudex.upload(path) do
      {:ok, uploaded_image} -> {:ok, uploaded_image.secure_url}

      {_, error} -> {:cloudinary_error, error}
    end
  end

  defp get_url(params) do
    case  Map.has_key?(params, "url") do
      true -> {:ok, params["url"].path}

      _ -> {:url_error, "Key error"}
    end
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, path} <- get_url(product_params),
         {:ok, url} <- upload_image_to_cloudinary("#{path}"),
         {:ok, product} <- Products.create_product(Map.put(product_params, "url", url)) do
           conn
           |> put_flash(:info, "Product created successfully.")
           |> redirect(to: Routes.product_path(conn, :show, product))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
      {:cloudinary_error, error_msg} ->
        conn
        |> put_flash(:info, "#{error_msg}")
        |> render("new.html", changeset: Products.change_product(%Product{}))
      {:url_error, _} ->
        conn
        |> put_flash(:info, "Please upload image")
        |> render("new.html", changeset: Products.change_product(%Product{}))
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    LiveView.Controller.live_render(conn, Index, session: %{"product" => product})
  end

  def edit(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    changeset = Products.change_product(product)
    render(conn, "edit.html", product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(id)

    case Products.update_product(product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: Routes.product_path(conn, :show, product))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", product: product, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    {:ok, _product} = Products.delete_product(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: Routes.product_path(conn, :index))
  end
end
