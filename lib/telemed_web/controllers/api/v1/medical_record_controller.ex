defmodule TelemedWeb.API.V1.MedicalRecordController do
  use TelemedWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Telemed.MedicalRecords
  alias Telemed.MedicalRecords.MedicalRecord

  action_fallback TelemedWeb.API.FallbackController

  tags ["Medical Records"]

  operation :index,
    summary: "📋 Liste des dossiers médicaux",
    description: """
    Récupère la liste des DME selon le rôle:
    - **Patient**: Ses propres dossiers uniquement
    - **Doctor**: Tous les dossiers de ses patients
    - **Admin**: Tous les dossiers de la plateforme

    ### Filtres disponibles (query params)
    - `category`: Filtrer par catégorie (consultation, exam, etc.)
    - `priority`: Filtrer par priorité (low, normal, high, urgent)
    - `status`: Filtrer par statut (active, archived, draft)
    - `tags`: Filtrer par tags (séparés par virgules)

    ### Exemple
    ```
    GET /api/v1/medical_records?category=consultation&priority=high
    ```
    """,
    parameters: [
      category: [
        in: :query,
        type: :string,
        description: "Filtrer par catégorie",
        example: "consultation",
        required: false
      ],
      priority: [
        in: :query,
        type: :string,
        description: "Filtrer par priorité",
        example: "high",
        required: false
      ]
    ],
    responses: [
      ok: {"✅ Liste des DME récupérée avec succès", "application/json", TelemedWeb.Schemas.MedicalRecord.MedicalRecordListResponse},
      unauthorized: {"🔒 Authentification requise", "application/json", TelemedWeb.Schemas.Common.UnauthorizedResponse}
    ],
    security: [%{"bearer" => []}]

  def index(conn, params) do
    user = conn.assigns.current_user

    records = case user.role do
      "patient" ->
        MedicalRecords.list_user_records(user.id)
      "doctor" ->
        MedicalRecords.list_doctor_records(user.id, params)
      "admin" ->
        MedicalRecords.list_all_records(params)
      _ ->
        []
    end

    json(conn, %{data: Enum.map(records, &serialize_record/1)})
  end

  operation :create,
    summary: "📝 Créer un dossier médical (médecin uniquement)",
    description: """
    Crée un nouveau DME avec structure SOAP.

    ### 🔐 Permissions
    **Réservé aux médecins** (`role: doctor`)

    ### 📋 Structure SOAP
    - **S**ubjective: Symptômes rapportés par le patient
    - **O**bjective: Observations et examens cliniques
    - **A**ssessment: Diagnostic et évaluation
    - **P**lan: Plan de traitement et suivi

    ### Exemple complet
    ```json
    {
      "medical_record": {
        "user_id": 1,
        "nom": "Jean Dupont",
        "age": 45,
        "category": "consultation",
        "priority": "normal",
        "soap_subjective": "Patient se plaint de maux de tête persistants depuis 3 jours. Intensité 7/10.",
        "soap_objective": "Tension: 130/85 mmHg, Température: 37.2°C, Pouls: 75 bpm régulier. Pas de raideur nuque.",
        "soap_assessment": "Probable céphalée de tension. Pas de signe d'urgence neurologique.",
        "soap_plan": "Paracétamol 1g 3x/jour pendant 5j. Revoir si symptômes persistent ou s'aggravent.",
        "tags": ["céphalée", "suivi_requis", "prescription"]
      }
    }
    ```
    """,
    request_body: {"Données du DME", "application/json", TelemedWeb.Schemas.MedicalRecord.CreateMedicalRecordRequest},
    responses: [
      created: {"✅ DME créé avec succès", "application/json", TelemedWeb.Schemas.MedicalRecord.MedicalRecordResponse},
      forbidden: {"❌ Accès refusé - Réservé aux médecins", "application/json", TelemedWeb.Schemas.Common.ForbiddenResponse},
      unprocessable_entity: {"⚠️ Erreur de validation", "application/json", TelemedWeb.Schemas.Auth.ErrorResponse}
    ],
    security: [%{"bearer" => []}]

  def create(conn, %{"medical_record" => record_params}) do
    user = conn.assigns.current_user

    if user.role != "doctor" do
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Seuls les médecins peuvent créer des DME"}})
    else
      record_params = Map.put(record_params, "doctor_id", user.id)

      case MedicalRecords.create_medical_record(record_params) do
        {:ok, %MedicalRecord{} = record} ->
          conn
          |> put_status(:created)
          |> json(%{data: serialize_record(record)})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: %{message: "Erreur de validation", details: format_errors(changeset)}})
      end
    end
  end

  @doc "Afficher DME"
  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    case MedicalRecords.get_medical_record!(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: %{message: "DME non trouvé"}})

      record ->
        # Vérifier autorisation
        if can_access?(user, record) do
          json(conn, %{data: serialize_record(record)})
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: %{message: "Accès interdit"}})
        end
    end
  end

  @doc "Modifier DME"
  def update(conn, %{"id" => id, "medical_record" => record_params}) do
    user = conn.assigns.current_user
    record = MedicalRecords.get_medical_record!(id)

    if can_modify?(user, record) do
      case MedicalRecords.update_medical_record(record, record_params) do
        {:ok, updated_record} ->
          json(conn, %{data: serialize_record(updated_record)})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: %{message: "Erreur de validation", details: format_errors(changeset)}})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Accès interdit"}})
    end
  end

  @doc "Supprimer DME"
  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    record = MedicalRecords.get_medical_record!(id)

    if user.role == "admin" or record.doctor_id == user.id do
      case MedicalRecords.delete_medical_record(record) do
        {:ok, _} ->
          send_resp(conn, :no_content, "")

        {:error, _} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: %{message: "Impossible de supprimer"}})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Accès interdit"}})
    end
  end

  @doc "Liste DME d'un patient (pour médecin/admin)"
  def list_by_patient(conn, %{"patient_id" => patient_id}) do
    user = conn.assigns.current_user

    if user.role in ["doctor", "admin"] do
      records = MedicalRecords.list_user_records(patient_id)
      json(conn, %{data: Enum.map(records, &serialize_record/1)})
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Accès interdit"}})
    end
  end

  # Helpers privés
  defp can_access?(user, record) do
    user.role == "admin" or
    user.id == record.user_id or
    user.id == record.doctor_id
  end

  defp can_modify?(user, record) do
    user.role == "admin" or user.id == record.doctor_id
  end

  defp serialize_record(%MedicalRecord{} = record) do
    %{
      id: record.id,
      nom: record.nom,
      age: record.age,
      category: record.category,
      priority: record.priority,
      status: record.status,
      soap: %{
        subjective: record.soap_subjective,
        objective: record.soap_objective,
        assessment: record.soap_assessment,
        plan: record.soap_plan
      },
      diagnosis: record.diagnosis,
      treatment_plan: record.treatment_plan,
      consultation_date: record.consultation_date,
      follow_up_date: record.follow_up_date,
      tags: record.tags || [],
      attachments: record.attachments || %{},
      patient_id: record.user_id,
      doctor_id: record.doctor_id,
      inserted_at: record.inserted_at,
      updated_at: record.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
