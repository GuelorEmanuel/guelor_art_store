defmodule ArtStore.ChatsTest do
  use ArtStore.DataCase

  alias ArtStore.Chats

  describe "chats" do
    alias ArtStore.Chats.Chat

    @valid_attrs %{subject: "some subject"}
    @update_attrs %{subject: "some updated subject"}
    @invalid_attrs %{subject: nil}

    def chat_fixture(attrs \\ %{}) do
      {:ok, chat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chats.create_chat()

      chat
    end

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Chats.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Chats.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      assert {:ok, %Chat{} = chat} = Chats.create_chat(@valid_attrs)
      assert chat.subject == "some subject"
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, @update_attrs)
      assert chat.subject == "some updated subject"
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat(chat, @invalid_attrs)
      assert chat == Chats.get_chat!(chat.id)
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end

  # describe "messages" do
  #   alias ArtStore.Chats.Message

  #   @valid_attrs %{content: "some content"}
  #   @update_attrs %{content: "some updated content"}
  #   @invalid_attrs %{content: nil}

  #   def message_fixture(attrs \\ %{}) do
  #     {:ok, message} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Chats.create_message()

  #     message
  #   end

  #   test "list_messages/0 returns all messages" do
  #     message = message_fixture()
  #     assert Chats.list_messages() == [message]
  #   end

  #   test "get_message!/1 returns the message with given id" do
  #     message = message_fixture()
  #     assert Chats.get_message!(message.id) == message
  #   end

  #   test "create_message/1 with valid data creates a message" do
  #     assert {:ok, %Message{} = message} = Chats.create_message(@valid_attrs)
  #     assert message.content == "some content"
  #   end

  #   test "create_message/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Chats.create_message(@invalid_attrs)
  #   end

  #   test "update_message/2 with valid data updates the message" do
  #     message = message_fixture()
  #     assert {:ok, %Message{} = message} = Chats.update_message(message, @update_attrs)
  #     assert message.content == "some updated content"
  #   end

  #   test "update_message/2 with invalid data returns error changeset" do
  #     message = message_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, @invalid_attrs)
  #     assert message == Chats.get_message!(message.id)
  #   end

  #   test "delete_message/1 deletes the message" do
  #     message = message_fixture()
  #     assert {:ok, %Message{}} = Chats.delete_message(message)
  #     assert_raise Ecto.NoResultsError, fn -> Chats.get_message!(message.id) end
  #   end

  #   test "change_message/1 returns a message changeset" do
  #     message = message_fixture()
  #     assert %Ecto.Changeset{} = Chats.change_message(message)
  #   end
  # end

  # describe "participants" do
  #   alias ArtStore.Chats.Participant

  #   @valid_attrs %{last_read: ~N[2010-04-17 14:00:00]}
  #   @update_attrs %{last_read: ~N[2011-05-18 15:01:01]}
  #   @invalid_attrs %{last_read: nil}

  #   def participant_fixture(attrs \\ %{}) do
  #     {:ok, participant} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Chats.create_participant()

  #     participant
  #   end

  #   test "list_participants/0 returns all participants" do
  #     participant = participant_fixture()
  #     assert Chats.list_participants() == [participant]
  #   end

  #   test "get_participant!/1 returns the participant with given id" do
  #     participant = participant_fixture()
  #     assert Chats.get_participant!(participant.id) == participant
  #   end

  #   test "create_participant/1 with valid data creates a participant" do
  #     assert {:ok, %Participant{} = participant} = Chats.create_participant(@valid_attrs)
  #     assert participant.last_read == ~N[2010-04-17 14:00:00]
  #   end

  #   test "create_participant/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Chats.create_participant(@invalid_attrs)
  #   end

  #   test "update_participant/2 with valid data updates the participant" do
  #     participant = participant_fixture()
  #     assert {:ok, %Participant{} = participant} = Chats.update_participant(participant, @update_attrs)
  #     assert participant.last_read == ~N[2011-05-18 15:01:01]
  #   end

  #   test "update_participant/2 with invalid data returns error changeset" do
  #     participant = participant_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Chats.update_participant(participant, @invalid_attrs)
  #     assert participant == Chats.get_participant!(participant.id)
  #   end

  #   test "delete_participant/1 deletes the participant" do
  #     participant = participant_fixture()
  #     assert {:ok, %Participant{}} = Chats.delete_participant(participant)
  #     assert_raise Ecto.NoResultsError, fn -> Chats.get_participant!(participant.id) end
  #   end

  #   test "change_participant/1 returns a participant changeset" do
  #     participant = participant_fixture()
  #     assert %Ecto.Changeset{} = Chats.change_participant(participant)
  #   end
  # end

  describe "chatroles" do
    alias ArtStore.Chats.ChatRole

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def chat_role_fixture(attrs \\ %{}) do
      {:ok, chat_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chats.create_chat_role()

      chat_role
    end

    test "list_chatroles/0 returns all chatroles" do
      chat_role = chat_role_fixture()
      assert Chats.list_chatroles() == [chat_role]
    end

    test "get_chat_role!/1 returns the chat_role with given id" do
      chat_role = chat_role_fixture()
      assert Chats.get_chat_role!(chat_role.id) == chat_role
    end

    test "create_chat_role/1 with valid data creates a chat_role" do
      assert {:ok, %ChatRole{} = chat_role} = Chats.create_chat_role(@valid_attrs)
    end

    test "create_chat_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_role(@invalid_attrs)
    end

    test "update_chat_role/2 with valid data updates the chat_role" do
      chat_role = chat_role_fixture()
      assert {:ok, %ChatRole{} = chat_role} = Chats.update_chat_role(chat_role, @update_attrs)
    end

    test "update_chat_role/2 with invalid data returns error changeset" do
      chat_role = chat_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_role(chat_role, @invalid_attrs)
      assert chat_role == Chats.get_chat_role!(chat_role.id)
    end

    test "delete_chat_role/1 deletes the chat_role" do
      chat_role = chat_role_fixture()
      assert {:ok, %ChatRole{}} = Chats.delete_chat_role(chat_role)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat_role!(chat_role.id) end
    end

    test "change_chat_role/1 returns a chat_role changeset" do
      chat_role = chat_role_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat_role(chat_role)
    end
  end
end
