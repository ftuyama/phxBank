defmodule PhxBankWeb.BankController do
  use PhxBankWeb, :controller
  alias PhxBank.{Repo, Balance, Transaction, User}

  def operation(conn, params) do
    try do
      # A transactional operation
      Repo.transaction fn ->
        today = Ecto.Date.utc()

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
              amount:      params["transaction"]["amount"] |> amount_value,
              date:        params["transaction"]["date"] |> Ecto.Date.cast!
            })
          |> Repo.insert!

        # Calculates current user balance
        current_balance = Transaction.balance_diff(transaction, user.balance)

        # Updates/Creates today balance
        balance = Balance |> Balance.preload_all |> Repo.get_by(date: today)

        if balance == nil do
          balance = %Balance{}
            |> Balance.changeset(%{ user_id: user.id, amount: current_balance, date: today})
            |> Repo.insert!
        else
          balance = balance 
            |> Balance.changeset(%{amount: current_balance})
            |> Repo.update!
        end

        # Updates user balance
        user = user
          |> User.changeset(%{balance: current_balance})
          |> Repo.update!

        render conn, "operation.json", user: user, transaction: transaction
      end
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if params["debug"] == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end  

  def balance(conn, %{"user_id" => user_id, "debug" => debug}) do
    try do
      user = Repo.get!(User, user_id)
      render conn, "balance.json", user: user
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if debug == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end

  def statement(conn, %{"user_id" => user_id, "debug" => debug}) do
    try do
      user = Repo.get!(User, user_id)
      render conn, "statement.json", user: user
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if debug == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end

  def debits(conn, %{"user_id" => user_id, "debug" => debug}) do
    try do
      user = Repo.get!(User, user_id)
      render conn, "debits.json", user: user
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if debug == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end

  defp amount_value(amount) do
    case Float.parse(amount) do
      {num, ""} ->
        num |> Kernel.*(100) |> Kernel.round
      _ ->
        raise "Invalid amount"
    end
  end

  defp error_message(e) do
    if Map.get(e, "message"), do: "Error: #{e.message}", else: Exception.message(e)
  end
end
