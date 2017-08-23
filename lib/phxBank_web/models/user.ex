defmodule PhxBank.User do
  use Ecto.Schema
  alias PhxBank.{Balance, Transaction}

  schema "users" do
    field :name, :string
    field :username, :string
    field :balance, :integer, default: 0
    timestamps()

    has_many :balances, Balance
    has_many :transactions, Transaction
  end
end
