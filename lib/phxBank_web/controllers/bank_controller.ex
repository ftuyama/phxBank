defmodule PhxBankWeb.BankController do
  use PhxBankWeb, :controller
  alias PhxBank.{Repo, Transaction, User}

  def operation(conn, params) do
    try do
      user = Repo.get!(User, params["user_id"])
      transaction = Repo.insert!(
        %Transaction{
          user_id:     user.id, 
          description: params["transaction"]["description"], 
          type:        params["transaction"]["type"],
          amount:      params["transaction"]["amount"] |> String.to_integer,
          date:        params["transaction"]["date"] |> Ecto.Date.cast!()
        })
      render conn, "operation.json", user: user, transaction: transaction
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
