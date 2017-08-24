defmodule PhxBank.Repo.Migrations.CreateOperationAndBalance do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :type, :string, null: false
      add :description, :string, null: false
      add :amount, :integer, null: false
      add :date, :date, null: false
    end
    create index(:transactions, [:user_id])
    create index(:transactions, [:date])


    create table(:balances) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :amount, :integer, null: false
      add :date, :date, null: false
    end
    create index(:balances, [:user_id])
    create unique_index(:balances, [:date])
  end
end
