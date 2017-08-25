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

  def render("statement.json", %{user: user}) do
    %{
      user_id: user.id,
      user_name: user.name,
      balance: user.balance / 100.0,
      updated_at: user.updated_at
    }
  end  

  def render("debits.json", %{user: user}) do
    %{
      user_id: user.id,
      user_name: user.name,
      balance: user.balance / 100.0,
      updated_at: user.updated_at
    }
  end
end
