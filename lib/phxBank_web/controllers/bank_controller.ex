defmodule PhxBankWeb.BankController do
  use PhxBankWeb, :controller
  alias PhxBank.{Repo, Transaction, User}

  def operation(conn, _params) do
    render conn, "operation.json", json: %{}
  end
end
