defmodule Telemed.Documents.MedicalDocument do
  @moduledoc """
  Schema pour les documents médicaux (ordonnances, résultats, images, etc.)
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "medical_documents" do
    field :filename, :string
    field :file_path, :string
    field :content_type, :string
    field :file_size, :integer
    field :document_type, :string, default: "other"
    field :description, :string
    field :is_shared_with_patient, :boolean, default: true

    belongs_to :medical_record, Telemed.MedicalRecords.MedicalRecord
    belongs_to :uploaded_by, Telemed.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(medical_document, attrs) do
    medical_document
    |> cast(attrs, [
      :filename,
      :file_path,
      :content_type,
      :file_size,
      :document_type,
      :description,
      :is_shared_with_patient,
      :medical_record_id,
      :uploaded_by_id
    ])
    |> validate_required([:filename, :file_path, :medical_record_id, :uploaded_by_id])
    |> validate_inclusion(:document_type, [
      "prescription",
      "lab_result",
      "image",
      "scan",
      "report",
      "radiology",
      "other"
    ])
    |> validate_number(:file_size, greater_than: 0, less_than: 50_000_000)  # Max 50MB
    |> foreign_key_constraint(:medical_record_id)
    |> foreign_key_constraint(:uploaded_by_id)
  end

  @doc "Types de documents disponibles"
  def document_types do
    [
      {"Prescription", "prescription"},
      {"Résultat d'examen", "lab_result"},
      {"Image médicale", "image"},
      {"Scan/IRM", "scan"},
      {"Rapport médical", "report"},
      {"Radiologie", "radiology"},
      {"Autre", "other"}
    ]
  end

  @doc "Extensions de fichiers autorisées"
  def allowed_extensions do
    ~w(.pdf .jpg .jpeg .png .doc .docx .txt)
  end

  @doc "Taille maximale de fichier (en bytes)"
  def max_file_size, do: 50_000_000  # 50 MB
end
