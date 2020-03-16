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

user =
  %User{verified: true, name: "Guelor Emanuel", username: "lore", credential: %Credential{ email: "guelor.emanuel@alumni.carleton.ca", password_hash: Argon2.add_hash("superadmin1234").password_hash}}
  |> ArtStore.Repo.insert!()

root =
  %Role{role_name: "root"}
  |> ArtStore.Repo.insert!()

admin =
  %Role{role_name: "admin"}
  |> ArtStore.Repo.insert!()

limuser =
  %Role{role_name: "limuser"}
  |> ArtStore.Repo.insert!()

lore_user_role =
  %UserRole{user: user, role: root}
  |> ArtStore.Repo.insert!()


