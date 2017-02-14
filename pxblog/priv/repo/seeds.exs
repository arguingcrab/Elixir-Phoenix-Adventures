# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pxblog.Repo.insert!(%Pxblog.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Pxblog.Repo
alias Pxblog.Role
alias Pxblog.User

import Ecto.Query, only: [from: 2]

# Fix for duplicate data when running seeds

#Takes a role name and admin flag as args
#Based on those, we query Repo.all for the criteria in a switch/case
#  else already exists and skip
#Note ^vars - we don't want to do any pattern matching
find_or_create_role = fn role_name, admin ->
  case Repo.all(from r in Role, where: r.name == ^role_name and r.admin == ^admin) do
    [] ->
      %Role{}
      |> Role.changeset(%{name: role_name, admin: admin})
      |> Repo.insert!()
    _ ->
      IO.puts "Role: #{role_name} already exists, skipping"
  end
end

find_or_create_user = fn username, email, role ->
  case Repo.all(from u in User, where: u.username == ^username and u.email == ^email) do
    [] ->
      %User{}
      |> User.changeset(%{username: username, email: email, password: "test1234", password_confirmation: "test1234", role_id: role.id})
      |> Repo.insert!()
    _ ->
      IO.puts "User #{username} already exists, skipping"
  end
end

# Call the functions, note func"."args - This is required for anon func() calls
_user_role = find_or_create_role.("User Role", false)
# We need to reuse admin role to create admin user = no preface with _admin_role
admin_role = find_or_create_role.("Admin Role", true)
_admin_user = find_or_create_user.("admin", "admin@example.com", admin_role)
