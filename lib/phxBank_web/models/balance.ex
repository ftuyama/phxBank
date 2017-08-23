defmodule PhxBank.Balance do
  use Ecto.Schema
  alias PhxBank.User

  schema "balances" do
    field :amount, :integer, default: 0
    field :date, :date

    belongs_to :user, User
  end
end
