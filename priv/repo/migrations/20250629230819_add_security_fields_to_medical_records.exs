defmodule Telemed.Repo.Migrations.AddSecurityFieldsToMedicalRecords do
  use Ecto.Migration

  def change do
    # Supprimer tous les anciens dossiers médicaux
    execute "DELETE FROM medical_records"

    alter table(:medical_records) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :doctor_id, references(:users, on_delete: :nilify_all)
      add :record_type, :string, default: "consultation"
      add :confidentiality_level, :string, default: "private"
      add :status, :string, default: "active"
    end

    # Index pour les performances et la sécurité
    create index(:medical_records, [:user_id])
    create index(:medical_records, [:doctor_id])
    create index(:medical_records, [:record_type])
    create index(:medical_records, [:confidentiality_level])
  end
end
