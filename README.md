# PhxBank

Phoenix Bank web application with very basic features of a checking account.

## Requirements

Phoenix Bank application built using Erlang v19.0 and Elixir v1.5.1

SQLite database was used in order to simplify the solution.

You can install them using [`asdf Version Manager`](https://www.icicletech.com/blog/elixir-and-erlang-setup-with-asdf-version-manager)

## Installation instructions

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Run seeds to create demo user with `mix run priv/repo/seeds.exs`
  * Start Phoenix endpoint with `mix phx.server`
  * You can also run the app inside IEx (Interactive Elixir) with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## SQLite manipulation

If you want a full control/view of sqlite data, I suggest using [`sqlitebrowser:4000`](http://sqlitebrowser.org/)

  * One can install with `sudo apt install sqlitebrowser`

## Testing

  * Simply run tests with `mix test`

## Author

Felipe Tuyama
