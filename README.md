# ArtStore.Umbrella

This is my personal website, you can check it out at [gueloremanuel](https://gueloremanuel.com/).

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

Now you can visit my art store or personal website at`localhost:4000` or the chat app at `localhost:4000/chatter`, to signup or login to an already existing account.
