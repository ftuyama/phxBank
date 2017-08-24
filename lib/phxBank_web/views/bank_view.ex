defmodule PhxBankWeb.BankView do
  use PhxBankWeb, :view

  def render("operation.json", %{json: data}) do
    %{
      data: data
    }
  end  

  def render("balance.json", %{json: user}) do
    %{
      user_id: user.id,
      user_name: user.name,
      balance: user.balance,
      updated_at: user.updated_at
    }
  end  

  def render("statement.json", %{json: user}) do
    %{
      user_id: user.id,
      user_name: user.name,
      balance: user.balance,
      updated_at: user.updated_at
    }
  end  

  def render("periods.json", %{json: user}) do
    %{
      user_id: user.id,
      user_name: user.name,
      balance: user.balance,
      updated_at: user.updated_at
    }
  end
end
