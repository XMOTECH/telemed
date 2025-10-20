defmodule Telemed.Repo.Migrations.CreateMedicalDocuments do
  use Ecto.Migration

  def change do
    create table(:medical_documents) do
      # Informations fichier
      add :filename, :string, null: false
      add :file_path, :string, null: false
      add :content_type, :string
      add :file_size, :integer

      # Classification
      add :document_type, :string, default: "other"
      # Types: "prescription", "lab_result", "image", "scan", "report", "other"

      add :description, :text
      add :is_shared_with_patient, :boolean, default: true

      # Relations
      add :medical_record_id, references(:medical_records, on_delete: :delete_all)
      add :uploaded_by_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    # Index pour performance
    create index(:medical_documents, [:medical_record_id])
    create index(:medical_documents, [:uploaded_by_id])
    create index(:medical_documents, [:document_type])
    create index(:medical_documents, [:inserted_at])
  end
end
