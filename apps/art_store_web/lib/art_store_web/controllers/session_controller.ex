defmodule ArtStoreWeb.SessionController do
  use ArtStoreWeb, :controller

  alias ArtStore.Accounts
  alias ArtStore.Accounts.{User}
  alias ArtStore.Email
  alias ArtStore.Mailer

  alias Phoenix.LiveView
  alias ArtStoreWeb.SessionLive.Index


  def index(conn, _) do
    LiveView.Controller.live_render(conn, Index, session: %{})
  end

end
