defmodule ArtStoreWeb.SessionController do
  use ArtStoreWeb, :controller

  alias ArtStore.Accounts
  alias ArtStore.Accounts.{User}
  alias ArtStoreWeb.Email
  alias ArtStore.Mailer

  require Logger

  def index(conn, _) do
    render(conn, "index.html")
  end

  def login_page(conn, _) do
    render(conn, "login.html")
  end

  def signup(conn, _) do
    changeset = Accounts.change_user(%User{})

    render(conn, "signup.html", changeset: changeset)
  end

  def verification(conn, _) do
    render(conn, "confirm_verification.html")
  end

  defp check_password(user, given_pass) do
    Logger.warn("check_password user: #{inspect(user)}")
   case Argon2.check_pass(user.credential, given_pass) do
    {:ok, user} ->
      {:ok, user}
    {:error, msg} ->
      {:invalid_password, msg}
   end
  end

  defp login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)  #protects us from session fixation attacks, send the session cookie back to the client with a different identifier
  end

  defp is_user_verified(conn, user) do
    Logger.warn("user: #{inspect(user)}")
    case user.verified do
      true -> {:ok, user, conn}
      _ ->
        new_conn =
          conn
          |> put_session(:un_verified_user_id, user.id)
          |> configure_session(renew: true)

        {:user_is_not_verified, user, new_conn}
    end
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case login_by_username_and_pass(conn, email, password) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.chat_path(conn, :index))

      {:user_is_not_verified, user, new_conn} ->
        new_conn
        |> render("confirm_verification.html", user: user)
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Bad email/password combination")
        |> redirect(to: Routes.session_path(conn, :create))
    end
  end

  defp login_by_username_and_pass(conn, email, given_pass) do
    with {:ok, user} <- Accounts.authenticate_by_email_password(email),
         {:ok, _user} <- check_password(user, given_pass),
         {:ok, _user, _conn} <- is_user_verified(conn, user) do
           {:ok, login(conn, user)}
    else
      {:user_is_not_verified, user, new_conn} ->
        {:user_is_not_verified, user, new_conn}
      {:invalid_password, _} ->
        {:error, :unauthorized, conn}
      {:error, _} ->
        # Let simulate a password check with variable timing.
        # This hardens our authentication layer against timing attacks
        Logger.warn("no user found")
        Argon2.no_user_verify()
        {:error, :not_found, conn}
    end
  end

  defp cache_unverified_user(user, verification_code) do
   one_day_in_seconds = :timer.seconds(8_6400)
   user_value =  %{
                    "id" => "#{user.id}",
                    "user" => user,
                    "verification_code" => "#{verification_code}"
                  }

    ConCache.put(:current_user_cache,
                 String.to_atom("#{user.id}"),
                 %ConCache.Item{value: user_value, ttl: one_day_in_seconds})
  end

  defp send_verification_email(email, verification_code) do
    email
    |> Email.verification_code_email(verification_code)
    |> Mailer.deliver_later()
  end

  defp generate_verification_code() do
    verification_code = Enum.random(1_00009..9_99999)
  end

  defp send_verification_code(user, email) do
    verification_code = generate_verification_code()

    cache_unverified_user(user, verification_code)
    send_verification_email(email, verification_code)
  end

  def register_new_user(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        email = user.credential.email
        send_verification_code(user, email)

        conn
        |> put_flash(:info, "Please check your email.")
        |> put_session(:un_verified_user_id, user.id)
        |> render("confirm_verification.html", user: user)
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.warn("register_new_user: #{inspect(changeset)}")
        render(conn, "signup.html", changeset: changeset)
    end
  end

  defp get_user_verification_code(user_id) do
    case ConCache.get(:current_user_cache, String.to_atom(user_id)) do
      nil ->
        {:verification_code_expired, "Verification code has expired"}
      %{
        "id" => _,
        "user" => user,
        "verification_code" => verification_code
      } -> {:ok, {verification_code, user}}
    end
  end

  defp verify_verification_code(verification_code, %{"vericaton_input" => verificaton_input}, user) do
    case verification_code === verificaton_input do
      true -> {:ok, user}
      _ -> {:invalid_verification_code, user}
    end
  end

  defp get_session_helper(conn) do
    case get_session(conn, :user_id) do
      nil -> get_session(conn, :un_verified_user_id)
      _ -> get_session(conn, :user_id)
    end
  end

  def verify_new_user(conn, %{"user" => user_params}) do
    user_id = "#{get_session_helper(conn)}"

    Logger.warn("user_params #{inspect(user_params)}")

    with {:ok, {verification_code, user}} <- get_user_verification_code(user_id),
         {:ok, user} <- verify_verification_code(verification_code, user_params, user),
         {:ok, new_user} <- Accounts.update_user(user, %{"verified" => true}) do
          login(conn, new_user)
          |> redirect(to: Routes.chat_path(conn, :index))
    else
      {:verification_code_expired, _} ->
      Logger.warn("verification_code_expired: #{user_id}")
        user =
          user_id
          |> String.to_integer()
          |> Accounts.get_user!()

        email = user.credential.email

        user
        |> send_verification_code(email)

        conn
        |> put_flash(:info, "Expired verification code, please check your email for new verification code.")
        |> render("confirm_verification.html", user: user)
      {:invalid_verification_code, user} ->

        conn
        |> put_flash(:info, "The code you have entered is incorrect. Please try again.")
        |> render("confirm_verification.html", user: user)
      {:error, _} ->
        conn
        |> put_flash(:info, "Something went wrong. Please try again.")
        |> render("confirm_verification.html")

    end
  end

  def delete(conn, _) do
    update_in(conn.assigns, &Map.drop(&1, [:current_user]))
    |> configure_session(drop: true)
    |> redirect(to: Routes.session_path(conn, :index))
  end

  defp current_user(user_id) do
    current_user_from_cache_or_repo(user_id)
  end

  defp current_user_from_cache_or_repo(user_id) do
    ConCache.get_or_store(:current_user_cache, user_id, fn ->
      Accounts.get_user(user_id)
    end)
  end
end
