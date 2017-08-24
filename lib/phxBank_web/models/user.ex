defmodule PhxBank.User do
  use PhxBankWeb, :model

  alias PhxBank.{Balance, Transaction}

  schema "users" do
    field :name, :string
    field :username, :string
    field :balance, :integer, default: 0
    timestamps()

    has_many :balances, Balance
    has_many :transactions, Transaction
  end

  @required_fields ~w(name username)
  @optional_fields ~w(balance)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> slugify_username()
    |> validate_length(:username, min: 5)
    |> unique_constraint(:username, message: "Username already taken")
  end

  def preload_all(query) do
    from b in query, preload: [:transactions, :balances]
  end

  defp slugify_username(current_changeset) do
    if username = get_change(current_changeset, :username) do
      put_change(current_changeset, :username, slugify(username))
    else
      current_changeset
    end
  end

  defp slugify(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/, "-")
  end
end
