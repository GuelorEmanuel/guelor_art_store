defmodule ArtStore.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias ArtStore.Repo

  alias ArtStore.Chats
  alias ArtStore.Chats.Chat

  require Logger

  @doc """
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats do
    Repo.all(Chat)
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  @doc """
  Gets a single chat.

  Raises `nil` if the Chat does not exist.

  ## Examples

      iex> get_chat(123)
      %Chat{}

      iex> get_chat(456)
      ** nil

  """
  def get_chat(id) do
    query =
      from c in Chat,
        where: c.id == ^id,
        preload: [message: :user]

    Repo.one(query)
    |> Repo.preload([participant: :user])
  end

  @doc """
  Returns the list of chats.

  Raises `nil` if the Chats does not exist.

  ## Examples

      iex> get_curr_user_chats(123)
      %Chat{}

      iex> get_curr_user_chats(456)
      ** (Ecto.NoResultsError)

  """
  def get_curr_user_chats(id) do
    query =
      from c in Chat,
      inner_join: p in assoc(c, :participant),
      where: p.user_id == ^id

    query
    |> Repo.all()
    |> Repo.preload([participant: :user])
  end

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat_with_associationst(%{field: value}, chat_participant)
      {:ok, %Chat{}}

      iex> create_chat_with_associationst(%{field: bad_value}, chat_participant)
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_with_associationst(attrs \\ %{}, chat_participants) do
    Repo.transaction(fn ->
      chat =
        %Chat{}
         |> Chat.changeset(attrs)
         |> Repo.insert!()

      Enum.map(chat_participants,
                fn(chat_participant) ->
                  create_chat_role(chat_participant.user, chat, chat_participant.role)
                  create_participant(chat, chat_participant.user)
      end)
    end)
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{source: %Chat{}}

  """
  def change_chat(%Chat{} = chat) do
    Chat.changeset(chat, %{})
  end

  @doc """
  Check pivate chat uniqueness.

  ## Examples

      iex> is_private_chat_unique?(emails)
      true

  """
  def is_private_chat_unique?(email, curr_user_email) do
    query =
      from c in Chat,
        where: c.subject == ^"#{email}#{curr_user_email}" or c.subject == ^"#{curr_user_email}#{email}"

    query_result =
      query
      |> Repo.one()

    Logger.warn("query_result: #{inspect(query_result)}")
    case query_result do
      %Chat{} = _chat ->
        false
      nil -> true
    end
  end

  alias ArtStore.Chats.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert!()

    Chats.get_chat(attrs["chat_id"])
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

  def change_message do
    Message.changeset(%Message{}, %{})
  end

  def change_message(changeset, changes) do
    Message.changeset(changeset, changes)
  end

  alias ArtStore.Chats.Participant

  @doc """
  Returns the list of participants.

  ## Examples

      iex> list_participants()
      [%Participant{}, ...]

  """
  def list_participants do
    Repo.all(Participant)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id)

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%Chat{}, %User{})
      {:ok, %Participant{}}

      iex> create_participant(%Chat{}, %User{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(chat, user) do
    {:ok, datetime} = DateTime.now("Etc/UTC")

    %Participant{}
    |> Participant.changeset(%{"last_read" => datetime})
    |> Ecto.Changeset.put_assoc(:chat, chat)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert!()
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{source: %Participant{}}

  """
  def change_participant(%Participant{} = participant) do
    Participant.changeset(participant, %{})
  end

   @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the User role does not exist.

  ## Examples

      iex> get_participant_by_user_id(123)
      %UserRole{}

      iex> get_participant_by_user_id(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant_by_user_id(%{"chat_id" => chat_id, "user_id" => user_id}) do
    query =
      from p in Participant,
        where: p.user_id == ^user_id and p.chat_id == ^chat_id

    query_result =
      query
      |> Repo.one()

    case query_result do
      %Participant{} = participant ->
        participant
      nil -> nil
    end
  end

  alias ArtStore.Chats.ChatRole

  @doc """
  Returns the list of chatroles.

  ## Examples

      iex> list_chatroles()
      [%ChatRole{}, ...]

  """
  def list_chatroles do
    Repo.all(ChatRole)
  end

  @doc """
  Gets a single chat_role.

  Raises `Ecto.NoResultsError` if the Chat role does not exist.

  ## Examples

      iex> get_chat_role!(123)
      %ChatRole{}

      iex> get_chat_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat_role!(id), do: Repo.get!(ChatRole, id)

  @doc """
  Creates a chat_role.

  ## Examples

      iex> create_chat_role(%{field: value})
      {:ok, %ChatRole{}}

      iex> create_chat_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_role(attrs \\ %{}) do
    %ChatRole{}
    |> ChatRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  create_chat_role.

  ## Examples

      iex> create_chat_role(%User{}, %Chat{}, %Role{})
      {:ok, %ChatRole{}}

      iex> create_chat_role(%User{}, %Chat{}, %Role{})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_role(user, chat, role) do
    %ChatRole{}
    |> ChatRole.changeset(%{})
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:role, role)
    |> Ecto.Changeset.put_assoc(:chat, chat)
    |> Repo.insert!()
  end

  @doc """
  Updates a chat_role.

  ## Examples

      iex> update_chat_role(chat_role, %{field: new_value})
      {:ok, %ChatRole{}}

      iex> update_chat_role(chat_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat_role(%ChatRole{} = chat_role, attrs) do
    chat_role
    |> ChatRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat_role.

  ## Examples

      iex> delete_chat_role(chat_role)
      {:ok, %ChatRole{}}

      iex> delete_chat_role(chat_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat_role(%ChatRole{} = chat_role) do
    Repo.delete(chat_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat_role changes.

  ## Examples

      iex> change_chat_role(chat_role)
      %Ecto.Changeset{source: %ChatRole{}}

  """
  def change_chat_role(%ChatRole{} = chat_role) do
    ChatRole.changeset(chat_role, %{})
  end
end
