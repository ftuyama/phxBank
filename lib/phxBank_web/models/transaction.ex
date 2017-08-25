defmodule PhxBank.Transaction do
  use PhxBankWeb, :model

  alias PhxBank.User

  schema "transactions" do
    field :type, :string
    field :description, :string
    field :amount, :integer, default: 0
    field :date, :date

    belongs_to :user, User
  end

  @required_fields ~w(user_id type description amount date)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:type, ["debit", "credit"], message: "Type should be either credit or debit")
  end

  def preload_all(query) do
    from b in query, preload: [:user]
  end

  def balance_diff(transaction, balance) do
    case transaction.type do
      "credit" ->
        balance + transaction.amount
      "debit" ->
        balance - transaction.amount
      _ ->
        raise "Invalid transaction"
    end
  end
end
