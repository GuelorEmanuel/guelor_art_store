defmodule ArtStore.Chats.Chat do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias ArtStore.Chats.ChatRole
  alias ArtStore.Chats.{Chat, Message, Participant}


  schema "chats" do
    field :subject, :string
    field :is_group_chat, :boolean, default: true
    field :emails, {:array, :string}, virtual: true
    has_many :chat_role, ChatRole
    has_many :participant, Participant
    has_many :message, Message

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:subject, :is_group_chat, :emails])
    |> validate_required([:subject, :emails])
    |> validate_length(:emails, min: 1, max: 10)
    |> validate_emails(:emails)
  end

  def add_errors(attrs, errors) do
    changeset = changeset(%Chat{}, attrs)
    changeset = Ecto.Changeset.add_error(changeset, :emails, "#{errors}")
    {_, changeset} = Ecto.Changeset.apply_action(changeset, :create)

    changeset
  end


  defp validate_emails(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, emails ->
      case valid_email?(emails) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  defp valid_email?(emails) do
    Enum.reduce_while(emails, 0, fn email, _acc ->
      if Regex.run( ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, email) == nil, do:
        {:halt, {:error, "invalid email format"}},
        else:
          {:cont, {:ok, email}}
    end)
  end
end
