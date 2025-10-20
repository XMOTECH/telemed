defmodule Telemed.Repo.Migrations.AddPerformanceIndexes do
  use Ecto.Migration

  def change do
    # Index pour améliorer les performances des requêtes fréquentes
    create_if_not_exists index(:appointments, [:patient_id])
    create_if_not_exists index(:appointments, [:doctor_id])
    create_if_not_exists index(:appointments, [:scheduled_at])
    create_if_not_exists index(:appointments, [:status])

    create_if_not_exists index(:notifications, [:user_id, :read])
    create_if_not_exists index(:notifications, [:inserted_at])

    create_if_not_exists index(:medical_records, [:user_id])
    create_if_not_exists index(:medical_records, [:doctor_id])

    create_if_not_exists index(:users_tokens, [:user_id])
    create_if_not_exists index(:users_tokens, [:context])
  end
end
