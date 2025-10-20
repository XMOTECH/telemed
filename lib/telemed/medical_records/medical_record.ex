defmodule Telemed.MedicalRecords.MedicalRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "medical_records" do
    # === Champs originaux ===
    field :nom, :string
    field :age, :integer
    field :description, :string
    field :record_type, :string, default: "consultation"
    field :confidentiality_level, :string, default: "private"
    field :status, :string, default: "active"
    field :content, :string
    field :diagnosis, :string
    field :treatment_plan, :string

    # === SOAP Structure (Nouveau) ===
    field :soap_subjective, :string  # S - Symptômes rapportés
    field :soap_objective, :string   # O - Examens, observations
    field :soap_assessment, :string  # A - Diagnostic, évaluation
    field :soap_plan, :string        # P - Plan de traitement

    # === Type & Catégorie ===
    field :consultation_type, :string, default: "consultation"
    field :specialty, :string
    field :priority, :string, default: "normal"

    # === Tags & Organisation ===
    field :tags, {:array, :string}, default: []
    field :category, :string

    # === Attachments ===
    field :attachments, :map, default: %{}

    # === Metadata ===
    field :created_by_name, :string
    field :location, :string
    field :duration_minutes, :integer
    field :follow_up_date, :date
    field :consultation_date, :utc_datetime

    # === Relations ===
    belongs_to :user, Telemed.Accounts.User
    belongs_to :doctor, Telemed.Accounts.User
    belongs_to :last_modified_by, Telemed.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset pour création/édition complète
  """
  def changeset(medical_record, attrs) do
    medical_record
    |> cast(attrs, [
      # Originaux
      :nom, :age, :description, :user_id, :doctor_id,
      :record_type, :confidentiality_level, :status,
      :content, :diagnosis, :treatment_plan,
      # SOAP
      :soap_subjective, :soap_objective, :soap_assessment, :soap_plan,
      # Type & Catégorie
      :consultation_type, :specialty, :priority, :category,
      # Metadata
      :tags, :attachments, :created_by_name, :location,
      :duration_minutes, :follow_up_date, :consultation_date,
      :last_modified_by_id
    ])
    |> validate_required([:nom, :user_id])
    |> validate_inclusion(:priority, ["low", "normal", "high", "urgent"])
    |> validate_inclusion(:consultation_type, ["consultation", "exam", "treatment", "report", "follow_up"])
    |> validate_number(:age, greater_than: 0, less_than: 150)
    |> validate_number(:duration_minutes, greater_than: 0, less_than: 480)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:doctor_id)
    |> foreign_key_constraint(:last_modified_by_id)
  end

  @doc """
  Changeset simplifié pour quick edit
  """
  def quick_changeset(medical_record, attrs) do
    medical_record
    |> cast(attrs, [:soap_subjective, :soap_objective, :soap_assessment, :soap_plan, :tags])
    |> validate_required([])
  end

  @doc """
  Retourne le type avec emoji et couleur
  """
  def type_display(consultation_type) do
    case consultation_type do
      "consultation" -> %{emoji: "🩺", label: "Consultation", color: "blue"}
      "exam" -> %{emoji: "💉", label: "Examen", color: "purple"}
      "treatment" -> %{emoji: "💊", label: "Traitement", color: "green"}
      "report" -> %{emoji: "📋", label: "Rapport", color: "gray"}
      "follow_up" -> %{emoji: "🔄", label: "Suivi", color: "yellow"}
      _ -> %{emoji: "📄", label: "Autre", color: "gray"}
    end
  end

  @doc """
  Retourne la priorité avec couleur
  """
  def priority_display(priority) do
    case priority do
      "urgent" -> %{label: "Urgent", color: "red", badge: "bg-red-100 text-red-700"}
      "high" -> %{label: "Élevée", color: "orange", badge: "bg-orange-100 text-orange-700"}
      "normal" -> %{label: "Normal", color: "green", badge: "bg-green-100 text-green-700"}
      "low" -> %{label: "Faible", color: "gray", badge: "bg-gray-100 text-gray-700"}
      _ -> %{label: "Normal", color: "green", badge: "bg-green-100 text-green-700"}
    end
  end
end
