defmodule ArtStoreWeb.Email do
  import Bamboo.Email
  require Logger

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
    |> from("Chatter <ncstech07t@gmail.com>")
  end
end
