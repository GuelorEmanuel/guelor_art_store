defmodule ArtStoreWeb.Email do
  import Bamboo.Email

  def verification_code_email(email, verification_code) do
    base_email()
    |> to(email)
    |> subject("#{verification_code} is your Chatter verification code")
    |> text_body("verification code")
    |> html_body("<h1>Confirm your email address</h1>
                  <p>There's one quick step you need to complete before creating your Chatter account. Let's make sure this is the right email address for you - please confirm this is the right address to use for your new account</p>
                  <p>Please enter this verification code to get started with Chatter:</p>
                  <h1>#{verification_code}</h1>
                  <p>Verification codes expire after two hours</p>
                  <p>Thanks, <br>Chatter</p>"
                )
  end
  def verification_code_email(_) do
    {:error, "Invalid match"}
  end

  defp base_email() do
    new_email()
    |> from("Chatter <#{Application.get_env(:art_store, ArtStore.Mailer)[:ge_public_email]}>")
  end

  def chat_invite_email(emails, cur_user_name) do
    base_email()
    |> to(emails)
    |> subject("#{cur_user_name} Invited you to chat")
    |> text_body("Notification")
    |> html_body("<h1>#{cur_user_name} invited you to chat</h1>
                  <p>Visit your chatter account to respond to #{cur_user_name} </p>
                  <p>Thanks, <br>Chatter</p>"
                )
  end
end
