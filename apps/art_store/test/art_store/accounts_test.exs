defmodule ArtStore.AccountsTest do
  use ArtStore.DataCase

  alias ArtStore.Accounts
  alias ArtStore.Accounts.User

  def unload_relations(obj, to_remove \\ nil) do
    assocs =
      if to_remove == nil,
        do: obj.__struct__.__schema__(:associations),
      else: Enum.filter(obj.__struct__.__schema__(:associations), &(&1 in to_remove))

      Enum.reduce(assocs, obj, fn assoc, obj ->
        assoc_meta = obj.__struct__.__schema__(:association, assoc)

        Map.put(obj, assoc, %Ecto.Association.NotLoaded{
          __field__: assoc,
          __owner__: assoc_meta.owner,
          __cardinality__: assoc_meta.cardinality
        })
      end)
  end

  describe "users" do
    @valid_attrs %{username: "some  username", verified: true, name: "some name"}
    @update_attrs %{username: "some updated  username", verified: false, name: "some updated name"}
    @invalid_attrs %{username: nil, verified: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user. username == "some  username"
      assert user. verified == true
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user. username == "some updated  username"
      assert user. verified == false
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "credentials" do
    alias ArtStore.Accounts.Credential

    @valid_user_attrs %{username: "some  username", verified: true, name: "some name"}
    @valid_attrs %{email: "someemail@gueloremanuel.com", password: "some password"}
    @update_attrs %{email: "someupdatedemail@gueloremanuel.com", password: "some updated password"}
    @invalid_attrs %{email: nil, password_hash: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, user} =
        @valid_user_attrs
        |> Accounts.create_user()

      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_credential(user)

      Map.put(credential, :password, nil)
    end

    test "list_credentials/0 returns all credentials" do
      credential =
        credential_fixture()
        |> unload_relations()

      assert Accounts.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential =
        credential_fixture()
        |> unload_relations()

      assert Accounts.get_credential!(credential.id) == credential
    end

    test "create_credential/1 with valid data creates a credential" do
      {:ok, user} =
        @valid_user_attrs
        |> Accounts.create_user()

      assert {:ok, %Credential{} = credential} = Accounts.create_credential(@valid_attrs, user)
      assert credential.email == "someemail@gueloremanuel.com"
      assert Argon2.verify_pass("some password", credential.password_hash) == true
    end

    test "create_credential/1 with invalid data returns error changeset" do
      {:ok, user} =
        @valid_user_attrs
        |> Accounts.create_user()

      assert {:error, %Ecto.Changeset{}} = Accounts.create_credential(@invalid_attrs, user)
    end

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{} = credential} = Accounts.update_credential(credential, @update_attrs)
      assert credential.email == "someupdatedemail@gueloremanuel.com"
      assert Argon2.verify_pass("some updated password", credential.password_hash) == true
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential =
        credential_fixture()
        |> unload_relations()

      assert {:error, %Ecto.Changeset{}} = Accounts.update_credential(credential, @invalid_attrs)
      assert credential == Accounts.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Accounts.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Accounts.change_credential(credential)
    end
  end

  describe "roles" do
    alias ArtStore.Accounts.Role

    @valid_attrs %{role_name: "some role_name"}
    @update_attrs %{role_name: "some updated role_name"}
    @invalid_attrs %{role_name: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Accounts.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Accounts.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Accounts.create_role(@valid_attrs)
      assert role.role_name == "some role_name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, %Role{} = role} = Accounts.update_role(role, @update_attrs)
      assert role.role_name == "some updated role_name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_role(role, @invalid_attrs)
      assert role == Accounts.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Accounts.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_role(role)
    end
  end

  describe "userroles" do
    alias ArtStore.Accounts.UserRole

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def user_role_fixture(attrs \\ %{}) do
      {:ok, user_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_role()

      user_role
    end

    test "list_userroles/0 returns all userroles" do
      user_role = user_role_fixture()
      assert Accounts.list_userroles() == [user_role]
    end

    test "get_user_role!/1 returns the user_role with given id" do
      user_role = user_role_fixture()
      assert Accounts.get_user_role!(user_role.id) == user_role
    end

    test "create_user_role/1 with valid data creates a user_role" do
      assert {:ok, %UserRole{} = user_role} = Accounts.create_user_role(@valid_attrs)
    end

    test "create_user_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_role(@invalid_attrs)
    end

    test "update_user_role/2 with valid data updates the user_role" do
      user_role = user_role_fixture()
      assert {:ok, %UserRole{} = user_role} = Accounts.update_user_role(user_role, @update_attrs)
    end

    test "update_user_role/2 with invalid data returns error changeset" do
      user_role = user_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_role(user_role, @invalid_attrs)
      assert user_role == Accounts.get_user_role!(user_role.id)
    end

    test "delete_user_role/1 deletes the user_role" do
      user_role = user_role_fixture()
      assert {:ok, %UserRole{}} = Accounts.delete_user_role(user_role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_role!(user_role.id) end
    end

    test "change_user_role/1 returns a user_role changeset" do
      user_role = user_role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_role(user_role)
    end
  end
end
