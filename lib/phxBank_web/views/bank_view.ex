defmodule PhxBankWeb.BankView do
  use PhxBankWeb, :view

  def render("operation.json", %{user: user, transaction: transaction}) do
    %{
      user_id: user.id,
      user_name: user.name,
      balance: user.balance / 100.0,
      transaction: %{
        id: transaction.id,
        description: transaction.description,
        type: transaction.type,
        amount: transaction.amount / 100.0,
        date: transaction.date
      }
    }
  end  

  def render("balance.json", %{user: user}) do
    %{
      user_id: user.id,
      user_name: user.name,
      balance: user.balance / 100.0,
      updated_at: user.updated_at
    }
  end  

  def render("statement.json", %{transactions: transactions, balances: balances}) do
    statements = balances
      |> Enum.map(fn b -> %{
          date: b.date,
          balance: b.amount / 100.0,
          transactions: transactions[b.date] |> Enum.map(fn t -> %{
            id: t.id,
            type: t.type,
            description: t.description,
            amount: t.amount
          } end)
        } end)
    statements
  end  

  def render("debits.json", %{debits: debits_list}) do
    debits_list
  end
end
