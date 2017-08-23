defmodule PhxBankWeb.Router do
  use PhxBankWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhxBankWeb do
    pipe_through :api

    post "/operation", BankController, :operation
  end

  scope "/", PhxBankWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxBankWeb do
  #   pipe_through :api
  # end
end
