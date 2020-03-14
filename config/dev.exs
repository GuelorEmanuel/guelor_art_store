use Mix.Config

# Configure your database
config :art_store, ArtStore.Repo,
  username: "postgres",
  password: "postgres",
  database: "art_store_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :art_store_web, ArtStoreWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/art_store_web/assets", __DIR__)
    ]
  ],
  cancel_url: "http://localhost:4000/",
  success_url: "http://localhost:400/success?session_id=",
  stripe_pk: "pk_test_dG6vpZDNXycfGGBUBgxQ49Ko00fCGjSoCx"

config :stripity_stripe, api_key: "sk_test_NIwu1PjrpJGuaAKKw2s58PDX00Rg9WM2Y8"

config :cloudex,
    api_key: "915756558412773",
    secret: "VyH8QnQKXs6sXdJDSuapJ1HbFi4",
    cloud_name: "gueloremanuel-com"

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :art_store_web, ArtStoreWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/art_store_web/(live|views)/.*(ex)$",
      ~r"lib/art_store_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
