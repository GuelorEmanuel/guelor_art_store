# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :art_store, ArtStore.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer("1")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :art_store_web, ArtStoreWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

config :stripity_stripe, api_key: System.get_env("STRIPE_SECRET")

config :cloudex,
    api_key: System.get_env("CLOUDEX_API_KEY"),
    secret: System.get_env("CLOUDEX_SECRET"),
    cloud_name: System.get_env("CLOUDEX_CLOUD_NAME")

# Configure Bamboo Mailer
config :art_store, ArtStore.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :art_store_web, ArtStoreWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
