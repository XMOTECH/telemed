defmodule Telemed.Repo.Migrations.CreateAppointments do
  use Ecto.Migration

  def change do
    create table(:appointments) do
      add :scheduled_at, :naive_datetime
      add :status, :string
      add :notes, :text
      add :doctor_id, references(:users, on_delete: :nothing)
      add :patient_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:appointments, [:doctor_id])
    create index(:appointments, [:patient_id])
  end
end
