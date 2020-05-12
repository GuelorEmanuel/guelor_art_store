defmodule ArtStoreWeb.ChatController do
  use ArtStoreWeb, :controller

  alias ArtStore.Accounts
  alias ArtStore.Chats
  alias ArtStore.Chats.Chat
  alias Phoenix.LiveView
  alias ArtStoreWeb.ChatLive.Index
  alias ArtStoreWeb.Email
  alias ArtStore.Mailer

  require Logger

  def index(conn, _params) do
    user_id =  get_session(conn, :user_id)
    chats = Chats.get_curr_user_chats(user_id)
    render(conn, "index.html", chats: chats)
  end

  def new(conn, _params) do
    changeset = Chats.change_chat(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  defp verify_emails(nil), do: {:empty_emails_given, "Email cannot be empty, "}
  defp verify_emails(emails) when length(emails) == 1, do: {:ok, emails}
  defp verify_emails(emails) when length(emails) > 9, do: {:exceed_maximum_parti, emails}
  defp verify_emails(emails) do
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
    chat_participant = [%{user: curr_user, role: Accounts.get_role_by_name("Owner")}]
    agent_role = Accounts.get_role_by_name("Agent")

    result = Enum.reduce credentials, [], fn credential, acc ->
      [%{user: credential.user, role: agent_role}] ++ acc
    end
    {:ok, result ++ chat_participant}
  end

  defp add_is_group_chat_field(%{"emails" => emails} = params, curr_user_email) do
     case length(emails) > 1 do
      true -> {:ok, params, true}
      false ->
        [head | _tail] = emails
        new_map =
          params
          |> Map.put("is_group_chat", false)
          |> Map.put("subject", "#{curr_user_email}#{head}")
        {:ok, new_map, false}
     end
  end

  defp maintain_private_chat_uniqueness(is_group, emails, _curr_user_email) when is_group, do: {:ok, emails}
  defp maintain_private_chat_uniqueness(_is_group, [head | _tail], curr_user_email) do
    case Chats.is_private_chat_unique?(head, curr_user_email) do
      true -> {:ok, head}
      false -> {:chat_already_exist, head}
    end

  end
  def create(conn, %{"chat" => chat_params}) do
    emails = chat_params["emails"]

    with {:ok, emails} <- verify_emails(emails),
         {:ok, curr_user} <- check_emails_contains_curr_user_session(conn, emails),
         {:ok, chat_params, is_group} <- add_is_group_chat_field(chat_params, curr_user.credential.email),
         {:ok, _} <- maintain_private_chat_uniqueness(is_group, emails, curr_user.credential.email),
         {:ok, credentials} <- check_invited_user_account_exist(emails),
         {:ok, chat_participants} <- prep_fields_for_create_chat_insert(curr_user, credentials),
         {:ok, participants} <- Chats.create_chat_with_associationst(chat_params, chat_participants) do

          emails
          |> Email.chat_invite_email(curr_user.name)
          |> Mailer.deliver_later() # Sends an email in the background using Task.Supervisor.

          chat = List.first(participants).chat

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
      {:chat_already_exist, _} ->
        changeset = Chat.add_errors(chat_params, "This chat already exist. ")
        render(conn, "new.html", changeset: changeset)
      {:exceed_maximum_parti, _} ->
        changeset = Chat.add_errors(chat_params, "Group chat can only be between 3-10 users. ")
        render(conn, "new.html", changeset: changeset)
      {:empty_emails_given , message} ->
        changeset = Chat.add_errors(chat_params, message)
        render(conn, "new.html", changeset: changeset)
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_id =  get_session(conn, :user_id)

    case Chats.get_participant_by_user_id(%{"chat_id" => id, "user_id" => user_id}) do
      nil ->
        conn
        |> put_flash(:info, "Chat couldn't be found.")
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

  defp handle_delete_chat(conn, chat_id, %{participant: participants} = chat) do
    user_id = get_session(conn, :user_id)
    chat_role = Chats.get_curr_user_chats_role(chat_id, user_id)
    %{role: %{role_name: role_name}} = chat_role

    participant = Enum.find(participants, fn(participant) ->
      participant.user_id == user_id
    end)

    case role_name do
      "Agent" ->
        {:ok, _chat} = Chats.delete_participant(participant)

        conn
        |> put_flash(:info, "You left chat successfully.")
      "Owner" ->
        {:ok, _chat} = Chats.delete_chat(chat)

        conn
        |> put_flash(:info, "Chat deleted successfully.")
    end
  end

  defp is_email_valid?(email) do
    String.match?(email, ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end

  defp check_number_of_user_constraint(chat_id) do
    case Chats.get_participant_by_chat_id(chat_id) + 1 do
      11 -> {:chat_room_is_full, chat_id}
      _ -> {:ok, chat_id}
    end
  end

  defp check_user_account_exist(email) do
    case Accounts.get_credentials_by_emails([email]) do
      [] -> {:user_not_found, email}
      [head| _tail] -> {:ok, head}
    end
  end

  defp is_user_already_in_chat(chat_id, user) do
    case Chats.get_participant_by_user_id(%{"chat_id" => chat_id, "user_id" => user.id}) do
      nil ->
        {:ok, user}
      _participant ->
        {:user_already_exist, user}
    end
  end

  defp invite_user_to_chat(chat_id, user_id) do
    case Chats.add_user_to_chat(chat_id, user_id) do
      {:ok, participant} -> {:ok, participant}
      _ -> {:error, "Something went wrong"}
    end
  end

  def add_user_to_chat(conn, %{"email" => email, "chat" => %{"chat_id" => chat_id},
                               "user" => %{"name" => name}}) do
    with true <- is_email_valid?(email),
         {:ok, _} <- check_number_of_user_constraint(chat_id),
         {:ok, credential} <- check_user_account_exist(email),
         {:ok, user} <- is_user_already_in_chat(chat_id, credential.user),
         {:ok, _participant} <- invite_user_to_chat(chat_id, user.id) do

          [email]
          |> Email.chat_invite_email(name)
          |> Mailer.deliver_later() # Sends an email in the background using Task.Supervisor.

          conn
          |> put_flash(:info, "#{user.name} has been added to chat.")
          |> redirect(to: Routes.chat_path(conn, :index))
    else
    false ->
      conn
      |> put_flash(:info, "#{email} is not a valid email address.")
      |> redirect(to: Routes.chat_path(conn, :index))
    {:user_already_exist, user} ->
      conn
      |> put_flash(:info, "#{user.name} is already in this chat.")
      |> redirect(to: Routes.chat_path(conn, :index))
    {:user_not_found, email} ->
      conn
      |> put_flash(:info, "The following user with email: #{email} doesn't exist.")
      |> redirect(to: Routes.chat_path(conn, :index))
    {:chat_room_is_full, _} ->
      conn
      |> put_flash(:info, "The chat room is already full.")
      |> redirect(to: Routes.chat_path(conn, :index))
    {:error, message} ->
      conn
      |> put_flash(:info, message)
      |> redirect(to: Routes.chat_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)

    conn
    |> handle_delete_chat(id, chat)
    |> redirect(to: Routes.chat_path(conn, :index))
  end

  defp current_user_from_cache_or_repo(user_id) do
    ConCache.get_or_store(:current_user_cache, user_id, fn ->
      Accounts.get_user!(user_id)
    end)
  end

  # Every controller has its own default action function.
  # It’s a plug that dispatches to the proper action at the end of the controller pipeline.

  # def action(conn, _) do
  #   # test this: conn.assigns.current_user
  #   apply(__MODULE__, action_name(conn),
  #   [conn, conn.params, conn.assigns.current_user])
  # end
end
