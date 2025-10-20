defmodule TelemedWeb.API.V1.AppointmentController do
  use TelemedWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Telemed.Appointments
  alias Telemed.Appointment
  alias TelemedWeb.Schemas

  action_fallback TelemedWeb.API.FallbackController

  tags ["Appointments"]

  operation :index,
    summary: "📅 Liste des rendez-vous",
    description: """
    Récupère la liste des RDV selon le rôle utilisateur.

    ### Permissions
    - **Patient**: Ses propres rendez-vous
    - **Doctor**: Rendez-vous avec ses patients
    - **Admin**: Tous les rendez-vous
    """,
    responses: [
      ok: {"✅ Liste récupérée", "application/json", Schemas.Appointment.AppointmentListResponse},
      unauthorized: {"🔒 Auth requise", "application/json", Schemas.Common.UnauthorizedResponse}
    ],
    security: [%{"bearer" => []}]

  def index(conn, _params) do
    user = conn.assigns.current_user

    appointments = case user.role do
      "patient" ->
        Appointments.list_patient_appointments(user.id)
      "doctor" ->
        Appointments.list_doctor_appointments(user.id)
      "admin" ->
        Appointments.list_appointments()
      _ ->
        []
    end

    json(conn, %{data: Enum.map(appointments, &serialize_appointment/1)})
  end

  @doc "Afficher RDV"
  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    appointment = Appointments.get_appointment!(id)

    if can_access?(user, appointment) do
      json(conn, %{data: serialize_appointment(appointment)})
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Accès interdit"}})
    end
  end

  operation :create,
    summary: "📝 Créer un rendez-vous",
    description: """
    Créer un nouveau RDV médical.

    ### Comportement
    - **Patient**: patient_id auto-assigné
    - **Doctor**: Peut spécifier patient_id

    ### Statut initial
    `pending` (en attente confirmation médecin)
    """,
    request_body: {"Données RDV", "application/json", Schemas.Appointment.AppointmentRequest},
    responses: [
      created: {"✅ RDV créé", "application/json", Schemas.Appointment.AppointmentResponse},
      unprocessable_entity: {"⚠️ Erreur validation", "application/json", Schemas.Auth.ErrorResponse}
    ],
    security: [%{"bearer" => []}]

  def create(conn, %{"appointment" => appointment_params}) do
    user = conn.assigns.current_user

    # Si patient, forcer patient_id
    appointment_params = if user.role == "patient" do
      Map.put(appointment_params, "patient_id", user.id)
    else
      appointment_params
    end

    case Appointments.create_appointment(appointment_params) do
      {:ok, %Appointment{} = appointment} ->
        conn
        |> put_status(:created)
        |> json(%{data: serialize_appointment(appointment)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: %{message: "Erreur de validation", details: format_errors(changeset)}})
    end
  end

  @doc "Modifier RDV"
  def update(conn, %{"id" => id, "appointment" => appointment_params}) do
    user = conn.assigns.current_user
    appointment = Appointments.get_appointment!(id)

    if can_modify?(user, appointment) do
      case Appointments.update_appointment(appointment, appointment_params) do
        {:ok, updated_appointment} ->
          json(conn, %{data: serialize_appointment(updated_appointment)})

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

  @doc "Supprimer RDV"
  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    appointment = Appointments.get_appointment!(id)

    if can_modify?(user, appointment) do
      case Appointments.delete_appointment(appointment) do
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

  @doc "Confirmer RDV (médecin)"
  def confirm(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    appointment = Appointments.get_appointment!(id)

    if user.role == "doctor" && appointment.doctor_id == user.id do
      case Appointments.update_appointment(appointment, %{"status" => "confirmed"}) do
        {:ok, updated_appointment} ->
          json(conn, %{data: serialize_appointment(updated_appointment)})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: %{message: "Erreur", details: format_errors(changeset)}})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Seul le médecin peut confirmer"}})
    end
  end

  @doc "Annuler RDV"
  def cancel(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    appointment = Appointments.get_appointment!(id)

    if can_modify?(user, appointment) do
      case Appointments.update_appointment(appointment, %{"status" => "cancelled"}) do
        {:ok, updated_appointment} ->
          json(conn, %{data: serialize_appointment(updated_appointment)})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: %{message: "Erreur", details: format_errors(changeset)}})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Accès interdit"}})
    end
  end

  # Helpers privés
  defp can_access?(user, appointment) do
    user.role == "admin" or
    user.id == appointment.patient_id or
    user.id == appointment.doctor_id
  end

  defp can_modify?(user, appointment) do
    user.role == "admin" or
    user.id == appointment.patient_id or
    user.id == appointment.doctor_id
  end

  defp serialize_appointment(%Appointment{} = appointment) do
    %{
      id: appointment.id,
      patient_id: appointment.patient_id,
      doctor_id: appointment.doctor_id,
      scheduled_at: appointment.scheduled_at,
      status: appointment.status,
      notes: appointment.notes,
      inserted_at: appointment.inserted_at,
      updated_at: appointment.updated_at
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
