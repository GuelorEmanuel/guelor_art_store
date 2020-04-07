# ArtStoreWeb

## Prerequisites:

This guide assumes you already have the following set up:

* Elixir (1.10.2 or better)
* npm (@6.13.7 as of this writing)
* Docker (optional, for running PostgreSQL)

If you don't have Elixir (and Erlang) yet, I highly recommend [asdf](https://asdf-vm.com/#/) to manage Elixir/Erlang versions.

Install [asdf](https://asdf-vm.com/#/) according to your platform's instructions.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
