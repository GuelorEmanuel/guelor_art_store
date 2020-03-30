defmodule ArtStoreWeb.ChatView do
  use ArtStoreWeb, :view
  require Logger

  def get_participant_name(participants, current_user) do
    participant = Enum.find(participants, fn(participant) -> participant.user_id !== current_user.id end)
    participant.user.name
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
