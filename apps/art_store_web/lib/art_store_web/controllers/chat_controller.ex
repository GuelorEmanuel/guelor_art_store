defmodule ArtStoreWeb.ChatController do
  use ArtStoreWeb, :controller

  alias ArtStore.Chats
  alias ArtStore.Chats.Chat

  def index(conn, _params) do
    chats = Chats.list_chats()
    render(conn, "index.html", chats: chats)
  end

  def new(conn, _params) do
    changeset = Chats.change_chat(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chat" => chat_params}) do
    case Chats.create_chat(chat_params) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat created successfully.")
        |> redirect(to: Routes.chat_path(conn, :show, chat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)
    render(conn, "show.html", chat: chat)
  end

  def edit(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)
    changeset = Chats.change_chat(chat)
    render(conn, "edit.html", chat: chat, changeset: changeset)
  end

  def update(conn, %{"id" => id, "chat" => chat_params}) do
    chat = Chats.get_chat!(id)

    case Chats.update_chat(chat, chat_params) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat updated successfully.")
        |> redirect(to: Routes.chat_path(conn, :show, chat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", chat: chat, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)
    {:ok, _chat} = Chats.delete_chat(chat)

    conn
    |> put_flash(:info, "Chat deleted successfully.")
    |> redirect(to: Routes.chat_path(conn, :index))
  end
end
