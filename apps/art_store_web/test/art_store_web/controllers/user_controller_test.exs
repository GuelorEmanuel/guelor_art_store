defmodule ArtStoreWeb.UserControllerTest do
  use ArtStoreWeb.ConnCase

  alias ArtStore.Accounts

  @create_attrs %{username: "some  username", verified: true, name: "some name"}
  @valid_credential_attrs %{email: "someemail@gueloremanuel.com", password: "some password"}
  @update_attrs %{username: "some updated  username", verified: false, name: "some updated name"}
  @invalid_attrs %{username: nil, verified: nil, name: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  # describe "index" do
  #   test "lists all users", %{conn: conn} do
  #     conn = get(conn, Routes.user_path(conn, :index))
  #     assert html_response(conn, 200) =~ "Listing Users"
  #   end
  # end

  # describe "new user" do
  #   test "renders form", %{conn: conn} do
  #     conn = get(conn, Routes.user_path(conn, :new))
  #     assert html_response(conn, 200) =~ "New User"
  #   end
  # end

  # describe "create user" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     params =
  #       @create_attrs
  #       |> Map.put(:credential, @valid_credential_attrs)
  #     conn = post(conn, Routes.user_path(conn, :create), user: params)

  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == Routes.user_path(conn, :show, id)

  #     conn = get(conn, Routes.user_path(conn, :show, id))
  #     assert html_response(conn, 200) =~ "Show User"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "New User"
  #   end
  # end

  # describe "edit user" do
  #   setup [:create_user]

  #   test "renders form for editing chosen user", %{conn: conn, user: user} do
  #     conn = get(conn, Routes.user_path(conn, :edit, user))
  #     assert html_response(conn, 200) =~ "Edit User"
  #   end
  # end

  # describe "update user" do
  #   setup [:create_user_and_credential]

  #   test "redirects when data is valid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #     assert redirected_to(conn) == Routes.user_path(conn, :show, user)

  #     conn = get(conn, Routes.user_path(conn, :show, user))
  #     assert html_response(conn, 200) =~ "some updated  username"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "Edit User"
  #   end
  # end

  # describe "delete user" do
  #   setup [:create_user]

  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, Routes.user_path(conn, :delete, user))
  #     assert redirected_to(conn) == Routes.user_path(conn, :index)
  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.user_path(conn, :show, user))
  #     end
  #   end
  # end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp create_user_and_credential(_) do
    user = fixture(:user)

    {:ok, _credential} =
      @valid_credential_attrs
      |> Accounts.create_credential(user)

    {:ok, user: user}
  end
end
