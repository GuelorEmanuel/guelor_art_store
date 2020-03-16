defmodule ArtStoreWeb.Router do
  use ArtStoreWeb, :router

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

  scope "/", ArtStoreWeb do
    pipe_through :browser

    get "/", ProductController, :index
    get "/art", PageController, :index
    get "/about", AboutController, :index
    get "/receipt", PurchaseController, :receipt
    resources "/store", ProductController, only: [:index, :show]
  end

  pipeline :chatter_layout do
    plug :put_layout, {ArtStoreWeb.LayoutView, :chatter}
  end

  scope "/chatter", ArtStoreWeb do
    pipe_through [:browser, :chatter_layout]

    get "/", SessionController, :index, singleton: true
    # get "/login", SessionController, :login_page, singleton: true
    # get "/signup", SessionController, :signup, singleton: true
  end

  scope "/admin", ArtStoreWeb do
    pipe_through :browser

    resources "/store", ProductController
    resources "/users", UserController
    resources "/purchases", PurchaseController, only: [:create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ArtStoreWeb do
  #   pipe_through :api
  # end
end
