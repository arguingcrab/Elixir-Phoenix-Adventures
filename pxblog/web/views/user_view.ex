defmodule Pxblog.UserView do
  use Pxblog.Web, :view

  @moduledoc """
  &/&1 - shorthand syntax for anon func()
  Equiv to
  Enum.map(roles, fn role -> ["(hash)(curly-open)role.name(curly-close)": role.id] end)

  Map returns a list of smaller keyword lists where role.name = key, role.id = val

  roles = [%Role{name: "Admin Role", id: 1}, %{Role{name: "User Role", id: 2}}]
  returns as
  [["Admin Role": 1], ["User Role": 2]]

  Pipe to List.flatten which compresses it to a list, and not a list of lists
  ["Admin Role": 1, "User Role": 2]
  """
  def roles_for_select(roles) do
    roles
    |> Enum.map(&["#{{&1.name}}": &1.id])
    |> List.flatten
  end
end
