defmodule PhxBankWeb.BankView do
  use PhxBankWeb, :view

  def render("operation.json", %{json: data}) do
    %{
      data: data
    }
  end
end
