defmodule PhxBankWeb.PageController do
  use PhxBankWeb, :controller
  alias PhxBank.{Repo, User}

  def index(conn, _params) do
    users = Repo.all(User) 
      |> maybe_create_user
    render conn, "index.html", users: users
  end

  defp maybe_create_user(users) do
    # Create default user if no one exists
    if Enum.count(users) == 0 do
      default_user = %User{} 
        |> User.changeset(%{
            name:     "Felipe Tuyama", 
            username: "ftuyama", 
            balance:  0
          }) 
        |> Repo.insert!
      [default_user | users]
    else
      users
    end
  end
end
