defmodule ArtStoreWeb.ChatController do
  use ArtStoreWeb, :controller

  alias ArtStore.Accounts
  alias ArtStore.Chats
  alias ArtStore.Chats.Chat
  alias Phoenix.LiveView
  alias ArtStoreWeb.ChatLive.Index

  require Logger

  def index(conn, _params) do
    user_id =  get_session(conn, :user_id)
    chats = Chats.get_curr_user_chat(user_id)
    render(conn, "index.html", chats: chats)
  end

  def new(conn, _params) do
    changeset = Chats.change_chat(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  defp check_emails_uniq(emails) when length(emails) == 1, do: {:ok, emails}
  defp check_emails_uniq(emails) do
    case length(emails) == length(Enum.uniq(emails)) do
      true -> {:ok, emails}
      false -> {:not_unique, emails}
    end
  end

  defp check_emails_contains_curr_user_session(conn, emails) do
    user_id =  get_session(conn, :user_id)
    curr_user = current_user_from_cache_or_repo(user_id)
    %{:credential => %{:email => value}} = curr_user

    case Enum.member?(emails, value) do
      true -> {:curr_user_email_exist, curr_user}
      false -> {:ok, curr_user}
    end
  end

  defp check_invited_user_account_exist(emails) do
    credentials = Accounts.get_credentials_by_emails(emails)

    case length(credentials) == length(emails) do
      true -> {:ok, credentials}
      false -> {:not_equal_in_length, credentials}
    end
  end

  defp prep_fields_for_create_chat_insert(curr_user, credentials) do
    Logger.warn("list_roles: #{inspect(Accounts.list_roles())}")
    chat_participant = [%{user: curr_user, role: Accounts.get_role_by_name("Owner")}]

    result = Enum.reduce credentials, [], fn credential, acc ->
      acc = [%{user: credential.user, role: Accounts.get_role_by_name("Agent")}] ++ acc
    end
    Logger.warn("result: #{inspect(result ++ chat_participant)}")
    {:ok, result ++ chat_participant}
  end
  def create(conn, %{"chat" => chat_params}) do
    # chat_params = Map.put_new(chat_params, "emails", nil)
    emails = chat_params["emails"]
    with {:ok, emails} <- check_emails_uniq(emails),
         {:ok, curr_user} <- check_emails_contains_curr_user_session(conn, emails),
         {:ok, credentials} <- check_invited_user_account_exist(emails),
         {:ok, chat_participant} <- prep_fields_for_create_chat_insert(curr_user, credentials),
         {:ok, participants} <- Chats.create_chat_with_associationst(chat_params, chat_participant) do
          # Create Chat role
          # Create Chat participants
          chat = List.first(participants).chat
          Logger.warn("chat: #{inspect(chat)}")
          conn
          |> put_flash(:info, "Chat created successfully.")
          |> redirect(to: Routes.chat_path(conn, :show, chat))
    else
      {:not_unique, _emails} ->
        changeset = Chat.add_errors(chat_params, "emails is not unique. ")
        render(conn, "new.html", changeset: changeset)
      {:curr_user_email_exist, _value} ->
        changeset = Chat.add_errors(chat_params, "You cannot add yourself. ")
        render(conn, "new.html", changeset: changeset)
      {:not_equal_in_length, _emails} ->
        changeset = Chat.add_errors(chat_params, "Some of the emails dont have an account with us. ")
        render(conn, "new.html", changeset: changeset)
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.warn("changeset: #{inspect(changeset)}")
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_id =  get_session(conn, :user_id)

    case Chats.get_participant_by_user_id(%{"chat_id" => id, "user_id" => user_id}) do
      nil ->
        conn
        |> put_flash(:info, "Chat updated successfully.")
        |> redirect(to: Routes.chat_path(conn, :index))
      _ ->
        chat = Chats.get_chat(id)
        LiveView.Controller.live_render(
          conn,
          Index,
          session: %{"chat" => chat, "current_user" => conn.assigns.current_user}
        )
    end
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

  defp current_user_from_cache_or_repo(user_id) do
    ConCache.get_or_store(:current_user_cache, user_id, fn ->
      Accounts.get_user!(user_id)
    end)
  end
end
