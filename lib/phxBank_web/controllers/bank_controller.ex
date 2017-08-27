defmodule PhxBankWeb.BankController do
  use PhxBankWeb, :controller
  alias PhxBank.{Repo, Balance, Transaction, User}

  def operation(conn, params) do
    try do
      # A transactional operation
      {:ok, %{user: user, transaction: transaction}} = 
        Repo.transaction fn ->
          # Gets the user
          user = User
            |> User.preload_all
            |> Repo.get!(params["user_id"])

          # Checks if transaction date is in the past
          transaction_date = params["transaction"]["date"] |> Ecto.Date.cast!
          
          if in_the_past(transaction_date) do
            # A daily balance is generated each day.
            # Adding a transaction in the past makes it necessary to
            #   recalculate (correct) all the following days.
            # Using this strategy saves time when calculating the balance
            #   along a large amount of transactions, but has this little problem.
            # I'm not implementing this now, just documenting here, lol
            raise "Transaction can't occur in the past"
          end

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
          balance = Balance |> Balance.preload_all |> Repo.get_by(date: transaction.date)

          if balance == nil do
            %Balance{}
              |> Balance.changeset(%{ user_id: user.id, amount: current_balance, date: transaction.date})
              |> Repo.insert!
          else
            balance 
              |> Balance.changeset(%{amount: current_balance})
              |> Repo.update!
          end

          # Updates user balance
          user = user
            |> User.changeset(%{balance: current_balance})
            |> Repo.update!

          %{user: user, transaction: transaction}
        end
      render conn, "operation.json", user: user, transaction: transaction
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if params["debug"] == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end  

  def balance(conn, params) do
    try do
      user = Repo.get!(User, params["user_id"])
      render conn, "balance.json", user: user
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if params["debug"] == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end

  def statement(conn, params) do
    try do
      # Statement parameters
      user = Repo.get!(User, params["user_id"])
      start_date = params["start"]  |> Ecto.Date.cast!
      end_date   = params["end"]    |> Ecto.Date.cast!

      # Gets all statement data
      transactions = 
        (from t in Transaction, 
          where:  t.date >= ^start_date,
          where:  t.date <= ^end_date,
          where:  t.user_id == ^user.id,
          select: t)
        |> Repo.all
        |> Enum.group_by( &Map.get(&1, :date) )

      balances = 
        (from b in Balance,
          where:    b.date >= ^start_date,
          where:    b.date <= ^end_date,
          where:    b.user_id == ^user.id,
          order_by: b.date,
          select:   b)
        |> Repo.all

      render conn, "statement.json", transactions: transactions, balances: balances
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if params["debug"] == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end

  def debits(conn, params) do
    try do
      # The daily balance strategy simplifies a lot our job now
      user = Repo.get!(User, params["user_id"])

      debits = 
        (from b in Balance,
          where:    b.user_id == ^user.id,
          order_by: b.date,
          select:   b)
        |> Repo.all

      # Maps debit balances to debit periods
      debits_list = Enum.reduce(debits, [], fn (d, list) ->
        current_debit = List.first(list)
        # Account balance has changed
        if current_debit == nil || d.amount != current_debit.amount do
          # Debit period is closed
          list =
            if current_debit != nil && Map.get(current_debit, :end_date) == nil do
              current_debit = Map.merge(current_debit, %{end_date: day_before(d.date)})
              List.replace_at(list, 0, current_debit)
            else
              list
            end
          # New debit period detected
          list =
            if d.amount < 0 do
              new_debit = %{amount: d.amount / 100.0, start_date: d.date}
              [new_debit | list]
            else
              list
            end
        end
      end)

      render conn, "debits.json", debits: debits_list
    rescue
      e in ErlangError -> 
        message = error_message(e)
        if params["debug"] == "true", do: raise e
        conn |> put_status(500) |> text(message)
    end
  end

  # Util functions

  defp in_the_past(transaction_date) do
    most_recent_balance = 
      Repo.one(from b in Balance, order_by: [desc: b.date], limit: 1)

    most_recent_balance != nil && 
      most_recent_balance
        |> Map.get(:date)
        |> Ecto.Date.cast! 
        |> Ecto.Date.compare(transaction_date) == :gt
  end

  defp day_before(date) do
    Timex.subtract(date, Timex.Duration.from_days(1))
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
