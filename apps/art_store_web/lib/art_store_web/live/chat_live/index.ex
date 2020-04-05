defmodule ArtStoreWeb.ChatLive.Index do
  use Phoenix.LiveView
  alias ArtStore.Chats
  alias ArtStoreWeb.Presence

  require Logger

  defp topic(chat_id), do: "chat:#{chat_id}"

  def render(assigns) do
    ArtStoreWeb.ChatView.render("show.html", assigns)
  end

  @spec mount(
          %{
            chat: atom | %{id: any, messages: any},
            current_user: atom | %{name: any, id: any}
          },
          Phoenix.LiveView.Socket.t()
        ) :: {:ok, any}
  def mount(%{"chat" => chat, "current_user" => current_user}, socket) do
    Presence.track_presence(
      self(),
      topic(chat.id),
      current_user.id,
      default_user_presence_payload(current_user)
    )

    ArtStoreWeb.Endpoint.subscribe(topic(chat.id))

    {:ok,
     assign(socket,
       chat: chat,
       message: Chats.change_message(),
       current_user: current_user,
       users: Presence.list_presences(topic(chat.id)),
       username_colors: username_colors(chat)
     )}
  end

  def handle_info(%{event: "presence_diff"}, socket = %{assigns: %{chat: chat}}) do
    {:noreply,
     assign(socket,
       users: Presence.list_presences(topic(chat.id))
     )}
  end

  def handle_info(%{event: "message", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  def handle_event("message", %{"message" => %{"content" => ""}}, socket) do
    {:noreply, socket}
  end

  def handle_event("message", %{"message" => message_params}, socket) do
    Logger.warn("handle_event-message: #{inspect(message_params)}")
    chat = Chats.create_message(message_params)
    ArtStoreWeb.Endpoint.broadcast_from(self(), topic(chat.id), "message", %{chat: chat})
    {:noreply, assign(socket, chat: chat, message: Chats.change_message())}
  end

  def handle_event("typing", _value, socket = %{assigns: %{chat: chat, current_user: user}}) do
    Presence.update_presence(self(), topic(chat.id), user.id, %{typing: true})
    {:noreply, socket}
  end

  def handle_event(
        "stop_typing",
        value,
        socket = %{assigns: %{chat: chat, current_user: user, message: message}}
      ) do
    message = Chats.change_message(message, %{content: value})
    Presence.update_presence(self(), topic(chat.id), user.id, %{typing: false})
    {:noreply, assign(socket, message: message)}
  end

  def handle_event("user_selected", %{"user" => ""}, socket),
    do: {:noreply, assign(socket,:user, nil)}

  def handle_event("user_selected", %{"user" => user_id_and_chat_id}, socket) do
    <<user_id, chat_id, curr_user_id>> = user_id_and_chat_id
    agent_chat_role = Chats.get_curr_user_chats_role(chat_id, user_id)
    admin_chat_role = Chats.get_curr_user_chats_role(chat_id, curr_user_id)

    with true <- is_chat_role_name_Admin?(admin_chat_role),
         {:ok, _} <- Chats.swap_chat_role(agent_chat_role, admin_chat_role) do
          Logger.warn("agent_chat_role: #{inspect(agent_chat_role)}")
          {:noreply,
            socket
            |> put_flash(:notice, "You are no longer admin of this chat room")
          }
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
      false ->
        {:noreply,
          socket
          |> put_flash(:notice, "You dont have permission to change the room role")
        }
    end
  end

  defp is_chat_role_name_Admin?(admin_chat_role) do
    admin_chat_role.role.role_name == "Owner"
  end

  defp default_user_presence_payload(user) do
    %{
      typing: false,
      name: user.name,
      user_id: user.id
    }
  end

  defp random_color do
    hex_code =
      ColorStream.hex()
      |> Enum.take(1)
      |> List.first()

    "##{hex_code}"
  end

  def username_colors(chat) do
    Enum.map(chat.message, fn message -> message.user end)
    |> Enum.map(fn user -> user.name end)
    |> Enum.uniq()
    |> Enum.into(%{}, fn name -> {name, random_color()} end)
  end
end
