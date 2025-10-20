defmodule Telemed.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :message, :text
      add :read, :boolean, default: false, null: false
      add :notification_type, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :appointment_id, references(:appointments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:appointment_id])
  end
end
