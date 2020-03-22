defmodule ArtStoreWeb.Router do
  use ArtStoreWeb, :router

  alias ArtStore.Accounts

  require Logger

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PhoenixGon.Pipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :chatter_layout do
    plug :put_layout, {ArtStoreWeb.LayoutView, :chatter}
  end

  pipeline :auth do
    plug :authenticate_user
  end

  pipeline :root_auth do
    plug :authenticate_root_user
  end

  pipeline :redirect_non_auth do
    plug :redirect_authicated_user
  end

  if Mix.env == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug

  end

  scope "/", ArtStoreWeb do
    pipe_through :browser

    get "/", ProductController, :index
    get "/art", PageController, :index
    get "/about", AboutController, :index
    get "/receipt", PurchaseController, :receipt
    resources "/store", ProductController, only: [:index, :show]
  end

  scope "/chatter", ArtStoreWeb do
    pipe_through :browser

    resources "/login", SessionController, only: [:delete], singleton: true
  end

  scope "/chatter", ArtStoreWeb do
    pipe_through [:browser, :chatter_layout, :redirect_non_auth]

    get "/", SessionController, :index, singleton: true
    get "/login", SessionController, :login_page, singleton: true
    get "/signup", SessionController, :signup, singleton: true
    post "/signup", SessionController, :register_new_user, singleton: true
    post "/verify", SessionController, :verify_new_user, singleton: true
    post "/login", SessionController, :create, singleton: true
  end

  scope "/chatter", ArtStoreWeb do
    pipe_through [:browser, :chatter_layout, :auth]

    resources "/chats", ChatController
  end

  scope "/admin", ArtStoreWeb do
    pipe_through [:browser, :root_auth]

    get "/create_product", ProductController, :admin
    resources "/store", ProductController
    resources "/users", UserController
    resources "/purchases", PurchaseController, only: [:create]
  end

  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/chatter/login")
        |> halt()
      user_id ->
        conn
        |> assign(:current_user, Accounts.get_user(user_id))
    end
  end

  defp check_user_root_status(conn) do
    case get_session(conn, :user_id) do
      nil ->
        {:not_root, nil}
      user_id ->
        user_role =
          Accounts.get_user(user_id).id
          |> Accounts.get_user_role_by_user_id()
        cond do
          user_role.role.role_name === "root" ->
            {:root, user_id}
          true ->
            {:not_root, nil}
        end
    end
  end

  defp authenticate_root_user(conn, _) do
    case check_user_root_status(conn) do
      {:not_root, _} ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()
      {:root, user_id} ->
        conn
        |> assign(:current_user, Accounts.get_user(user_id))
    end
  end

  defp redirect_authicated_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> assign(:current_user, nil)
      _user_id ->
        conn
        |> Phoenix.Controller.redirect(to: "/chatter/chats")
        |> halt()
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ArtStoreWeb do
  #   pipe_through :api
  # end
end
