defmodule ArtStoreWeb.SessionLive.Index do
  use Phoenix.LiveView

  alias ArtStoreWeb.SessionView

  def mount(_params, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    SessionView.render("index.html", assigns)
  end

end
