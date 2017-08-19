defmodule PhxBankWeb.PageController do
  use PhxBankWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
