defmodule PhxBank.Factory do
  use ExMachina.Ecto, repo: PhxBank.Repo
  alias PhxBank.{Repo, Balance, Transaction, User}

  def user_factory do
    %User{
      name: "Felipe Tuyama", 
      username: "ftuyama", 
      balance: 0
    }
  end

  def transaction_factory do
    %Transaction{
      user_id: 1,
      description: sequence(:description, &"Transaction #{&1}"),
      type: "debit",
      amount: 0.0,
      date: Ecto.Date.utc()
    }
  end  

  def balance_factory do
    %Balance{
      user_id: 1,
      amount: 0.0,
      date: Ecto.Date.utc()
    }
  end
end
