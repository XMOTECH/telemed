defmodule Telemed.Repo.Migrations.AddTitleAndTypeToNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :title, :string
      add :type, :string
    end
  end
end
