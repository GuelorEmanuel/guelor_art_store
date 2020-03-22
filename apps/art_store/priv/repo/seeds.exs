# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ArtStore.Repo.insert!(%ArtStore.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ArtStore.Accounts.{Role, User, UserRole, Credential}

root =
  %Role{role_name: "root"}
  |> ArtStore.Repo.insert!()

admin =
  %Role{role_name: "admin"}
  |> ArtStore.Repo.insert!()

limuser =
  %Role{role_name: "limuser"}
  |> ArtStore.Repo.insert!()

# Chat
owner =
  %Role{role_name: "Owner"}
  |> ArtStore.Repo.insert!()


%Role{role_name: "Agent"}
|> ArtStore.Repo.insert!()

