defmodule PhxBankWeb.BankController do
  use PhxBankWeb, :controller
  alias PhxBank.{Repo, Transaction, User}

  def operation(conn, params) do
    try do
      # A transactional operation
      Repo.transaction fn ->
        # Gets the user
        user = User
          |> User.preload_all
          |> Repo.get!(params["user_id"])

        # Generates a new Transaction
        transaction = %Transaction{}
          |> Transaction.changeset(%{
              user_id:     user.id, 
              description: params["transaction"]["description"], 
              type:        params["transaction"]["type"],
              amount:      params["transaction"]["amount"] |> String.to_integer,
              date:        params["transaction"]["date"] |> Ecto.Date.cast!
            })
          |> Repo.insert!

        # Updates/Creates today balance

        # Updates user balance
        user 
          |> User.changeset(%{
              amount: Transaction.balance_diff(transaction, user.balance)
            })
          |> User.update!

        render conn, "operation.json", user: user, transaction: transaction
      end
    rescue
      e in ErlangError -> message = "Error: #{e.message}"
      conn |> put_status(500) |> text(message)
    end
  end  

  def balance(conn, %{"user_id" => user_id}) do
    try do
      user = Repo.get!(User, user_id)
      render conn, "balance.json", user: user
    rescue
      e in ErlangError -> message = "Error: #{e.message}"
      conn |> put_status(500) |> text(message)
    end
  end

  def statement(conn, %{"user_id" => user_id}) do
    try do
      user = Repo.get!(User, user_id)
      render conn, "statement.json", user: user
    rescue
      e in ErlangError -> message = "Error: #{e.message}"
      conn |> put_status(500) |> text(message)
    end
  end

  def periods(conn, %{"user_id" => user_id}) do
    try do
      user = Repo.get!(User, user_id)
      render conn, "periods.json", user: user
    rescue
      e in ErlangError -> message = "Error: #{e.message}"
      conn |> put_status(500) |> text(message)
    end
  end
end
