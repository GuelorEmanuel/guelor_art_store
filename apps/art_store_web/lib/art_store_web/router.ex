defmodule ArtStoreWeb.Router do
  use ArtStoreWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  scope "/", ArtStoreWeb do
    pipe_through :browser

    get "/art", PageController, :index
    get "/about", AboutController, :index
    resources "/", ProductController
  end

  # Other scopes may use custom stacks.
  # scope "/api", ArtStoreWeb do
  #   pipe_through :api
  # end
end
