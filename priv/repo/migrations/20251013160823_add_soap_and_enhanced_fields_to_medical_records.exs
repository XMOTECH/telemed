defmodule Telemed.Repo.Migrations.AddSoapAndEnhancedFieldsToMedicalRecords do
  use Ecto.Migration

  def change do
    # Ajouter les champs SOAP (Subjective, Objective, Assessment, Plan)
    alter table(:medical_records) do
      # === SOAP Structure ===
      add :soap_subjective, :text  # S - Symptômes rapportés par le patient
      add :soap_objective, :text   # O - Examens, observations du médecin
      add :soap_assessment, :text  # A - Diagnostic, évaluation
      add :soap_plan, :text        # P - Plan de traitement, suivi

      # === Type & Catégorie ===
      add :consultation_type, :string, default: "consultation"  # consultation, exam, treatment, report
      add :specialty, :string  # cardiology, dermatology, general, etc.
      add :priority, :string, default: "normal"  # low, normal, high, urgent

      # === Tags & Organisation ===
      add :tags, {:array, :string}, default: []  # ["diabète", "hypertension", etc.]
      add :category, :string  # primary_care, follow_up, emergency, etc.

      # === Attachments & Files ===
      add :attachments, :map, default: %{}  # JSON: [{name, url, type, size, uploaded_at}]

      # === Metadata ===
      add :created_by_name, :string  # Nom du médecin pour affichage rapide
      add :location, :string  # Lieu de la consultation (cabinet, téléconsultation, etc.)
      add :duration_minutes, :integer  # Durée de la consultation
      add :follow_up_date, :date  # Date de prochain rendez-vous si nécessaire

      # === Recherche & Indexation ===
      add :search_vector, :tsvector  # Pour recherche full-text PostgreSQL

      # === Timestamps enrichis ===
      add :consultation_date, :utc_datetime  # Date réelle de la consultation
      add :last_modified_by, references(:users, on_delete: :nilify_all)
    end

    # Index pour performance
    create index(:medical_records, [:consultation_type])
    create index(:medical_records, [:specialty])
    create index(:medical_records, [:priority])
    create index(:medical_records, [:category])
    create index(:medical_records, [:consultation_date])
    create index(:medical_records, [:follow_up_date])
    create index(:medical_records, [:tags], using: "GIN")  # Index GIN pour arrays

    # Index pour recherche full-text (PostgreSQL)
    execute """
    CREATE INDEX medical_records_search_idx ON medical_records
    USING GIN (to_tsvector('french',
      coalesce(nom, '') || ' ' ||
      coalesce(description, '') || ' ' ||
      coalesce(soap_subjective, '') || ' ' ||
      coalesce(soap_objective, '') || ' ' ||
      coalesce(soap_assessment, '') || ' ' ||
      coalesce(soap_plan, '')
    ))
    """, """
    DROP INDEX IF EXISTS medical_records_search_idx
    """
  end
end
