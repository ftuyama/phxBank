defmodule PhxBankWeb.BankController do
  use PhxBankWeb, :controller
  alias PhxBank.{Repo, Transaction, User}

  def operation(conn, _params) do
    render conn, "operation.json", json: %{}
  end  

  def balance(conn, %{"user_id" => user_id}) do
    user = Repo.get(User, user_id)
    render conn, "balance.json", json: user
  end

  def statement(conn, %{"user_id" => user_id}) do
    user = Repo.get(User, user_id)
    render conn, "statement.json", json: user
  end

  def periods(conn, %{"user_id" => user_id}) do
    user = Repo.get(User, user_id)
    render conn, "periods.json", json: user
  end
end
