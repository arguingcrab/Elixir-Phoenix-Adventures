defmodule Pxblog.Role do
  use Pxblog.Web, :model

  schema "roles" do
    field :name, :string
    field :admin, :boolean, default: false

    timestamps()
    has_many :users, Pxblog.User
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(name admin)
  @optional_fields ~w()

  # def changeset(model, params \\ :empty) do
  def changeset(struct, params \\ %{}) do
    # model
    # |> cast(params, @required_fields, @optional_fields)
    struct
    |> cast(params, [:name, :admin])
    |> validate_required([:name, :admin])
  end
end
