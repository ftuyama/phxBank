defmodule PhxBank.Transaction do
  use Ecto.Schema
  alias PhxBank.User

  schema "transactions" do
    field :type, :string
    field :description, :string
    field :amount, :integer, default: 0
    field :datetime, :naive_datetime

    belongs_to :user, User
  end
end
