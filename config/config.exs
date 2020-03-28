# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :art_store,
  ecto_repos: [ArtStore.Repo]

config :art_store_web,
  ecto_repos: [ArtStore.Repo],
  generators: [context_app: :art_store]

# Configures the endpoint
config :art_store_web, ArtStoreWeb.Endpoint,
  url: [host: "gueloremanuel.com"],
  secret_key_base: "p11KmEmPjTlVabRIdWmDSOf15GLHA/99vaXP0KvJt2nyopwjzcoLNRRSHWsCUXYe",
  render_errors: [view: ArtStoreWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ArtStoreWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "gz6BPWYL"],
  check_origin: ["//gueloremanuel.com", "https://alarmed-purple-gerenuk.gigalixirapp.com"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
