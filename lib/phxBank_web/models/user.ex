defmodule PhxBank.User do
  use Ecto.Schema

  schema "users" do
    field :name
    field :username
    field :money,   :integer, default: 0
    timestamps()
  end
end
