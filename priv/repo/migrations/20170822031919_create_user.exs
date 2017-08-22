defmodule PhxBank.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :username, :string, null: false
      add :money, :integer
      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
