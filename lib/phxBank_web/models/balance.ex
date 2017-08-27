defmodule PhxBank.Balance do
  use PhxBankWeb, :model

  alias PhxBank.User

  schema "balances" do
    field :amount, :integer, default: 0
    field :date, :date

    belongs_to :user, User
  end

  @fields ~w(user_id amount date)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
  end

  def preload_all(query) do
    from b in query, preload: [:user]
  end
end
