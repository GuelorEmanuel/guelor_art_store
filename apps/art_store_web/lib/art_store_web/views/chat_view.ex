defmodule ArtStoreWeb.ChatView do
  use ArtStoreWeb, :view

  def get_participant_name(participants, current_user) do
    participant = Enum.find(participants, fn(participant) -> participant.user_id !== current_user.id end)
    participant.user.name
  end

  def is_chat_role_name_Admin?(chat_roles, current_user) do
    chat_role = Enum.find(chat_roles, fn(chat_role) ->
      chat_role.user_id == current_user.id
    end)
    chat_role.role.role_name == "Owner"
  end

  def filter_participant(participants, current_user) do
    Enum.filter(participants, fn(participant) ->
      participant.user.id != current_user.id
    end)
  end

  def filter_messages_by_joined_date(_participants, _current_user, messages, false), do: messages
  def filter_messages_by_joined_date(participants, current_user, messages, true) do
    %{inserted_at: inserted_at} = p = Enum.find(participants, fn(participant) ->
      participant.user_id == current_user.id end)
    Enum.filter(messages, fn(message) ->
      case DateTime.compare(message.inserted_at, inserted_at) do
        :gt -> true
        _ -> false
      end
    end)
  end

  def username_color(user, username_colors) do
      case Enum.find(username_colors, fn {name, _color} ->
                     name == user.name
                    end) do
        {_name, color} -> color
       _ -> nil
      end
  end

  @spec font_weight(atom | %{name: any}, atom | %{name: any}) :: <<_::32, _::_*16>>
  def font_weight(user, current_user) do
    if user.name == current_user.name do
      "bold"
    else
      "normal"
    end
  end

  def elipses(true), do: "..."
  def elipses(false), do: nil
end
