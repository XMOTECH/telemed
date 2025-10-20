defmodule TelemedWeb.AppointmentController do
  use TelemedWeb, :controller

  alias Telemed.Appointments
  alias Telemed.Appointment



  def index(conn, _params) do
    # Afficher tous les rendez-vous (plus de filtrage par utilisateur)
    appointments = Appointments.list_appointments() |> Telemed.Repo.preload([:doctor, :patient])
    render(conn, :index, appointments: appointments)
  end

  def new(conn, _params) do
    changeset = Appointments.change_appointment(%Appointment{})
    doctors = Telemed.Accounts.list_doctors()
    render(conn, :new, changeset: changeset, doctors: doctors)
  end

  def create(conn, %{"appointment" => appointment_params}) do
    # Utiliser un patient_id par défaut (ex: 1)
    processed_params = process_appointment_params(appointment_params, 1)
    case Appointments.create_appointment(processed_params) do
      {:ok, appointment} ->
        create_doctor_notification(appointment)
        conn
        |> put_flash(:info, "Rendez-vous créé avec succès. Le médecin sera notifié.")
        |> redirect(to: ~p"/appointments/#{appointment}")
      {:error, %Ecto.Changeset{} = changeset} ->
        doctors = Telemed.Accounts.list_doctors()
        render(conn, :new, changeset: changeset, doctors: doctors)
    end
  end

  def show(conn, %{"id" => id}) do
    appointment = Appointments.get_appointment!(id)
    render(conn, :show, appointment: appointment)
  end

  def confirm(conn, %{"appointment_id" => id}) do
    appointment = Appointments.get_appointment!(id)
    case Appointments.update_appointment(appointment, %{status: "confirmed"}) do
      {:ok, updated_appointment} ->
        create_patient_notification(updated_appointment, "confirmed")
        conn
        |> put_flash(:info, "Rendez-vous confirmé avec succès.")
        |> redirect(to: ~p"/appointments/#{updated_appointment}")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erreur lors de la confirmation du rendez-vous.")
        |> redirect(to: ~p"/appointments/#{appointment}")
    end
  end

  def reject(conn, %{"appointment_id" => id}) do
    appointment = Appointments.get_appointment!(id)
    case Appointments.update_appointment(appointment, %{status: "rejected"}) do
      {:ok, updated_appointment} ->
        create_patient_notification(updated_appointment, "rejected")
        conn
        |> put_flash(:info, "Rendez-vous refusé.")
        |> redirect(to: ~p"/appointments/#{updated_appointment}")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erreur lors du refus du rendez-vous.")
        |> redirect(to: ~p"/appointments/#{appointment}")
    end
  end

  def edit(conn, %{"id" => id}) do
    appointment = Appointments.get_appointment!(id)
    changeset = Appointments.change_appointment(appointment)
    render(conn, :edit, appointment: appointment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "appointment" => appointment_params}) do
    appointment = Appointments.get_appointment!(id)

    case Appointments.update_appointment(appointment, appointment_params) do
      {:ok, appointment} ->
        conn
        |> put_flash(:info, "Appointment updated successfully.")
        |> redirect(to: ~p"/appointments/#{appointment}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, appointment: appointment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    appointment = Appointments.get_appointment!(id)
    {:ok, _appointment} = Appointments.delete_appointment(appointment)

    conn
    |> put_flash(:info, "Appointment deleted successfully.")
    |> redirect(to: ~p"/appointments")
  end

  # Fonction pour traiter les paramètres de date et heure
  defp process_appointment_params(%{"scheduled_date" => date, "scheduled_time" => time} = params, patient_id) do
    scheduled_at = case DateTime.from_iso8601("#{date}T#{time}:00Z") do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
    params = Map.put(params, "patient_id", patient_id)
    params = Map.put(params, "status", "pending")
    params
    |> Map.delete("scheduled_date")
    |> Map.delete("scheduled_time")
    |> Map.put("scheduled_at", scheduled_at)
    |> Map.put("doctor_id", params["doctor_id"])
    |> Map.put("patient_id", params["patient_id"])
  end

  defp process_appointment_params(params, patient_id) do
    params = Map.put(params, "patient_id", patient_id)
    params
    |> Map.put("status", "pending")
    |> Map.put("doctor_id", params["doctor_id"])
    |> Map.put("patient_id", params["patient_id"])
  end

  # Fonction pour créer une notification pour le médecin
  defp create_doctor_notification(appointment) do
    if appointment.patient_id && appointment.doctor_id do
      patient = Telemed.Accounts.get_user!(appointment.patient_id)

      message = "Nouveau rendez-vous demandé par #{patient.first_name} #{patient.last_name} pour le #{format_datetime(appointment.scheduled_at)}"

      notification_params = %{
        user_id: appointment.doctor_id,
        title: "Nouveau rendez-vous",
        message: message,
        type: "appointment_created",
        appointment_id: appointment.id,
        read: false
      }

      Telemed.Notifications.create_notification(notification_params)
    end
  end

  # Ajoutons aussi un log lors de la notification patient (confirmation/refus)
  defp create_patient_notification(appointment, status) do
    doctor = Telemed.Accounts.get_user!(appointment.doctor_id)
    titre = if status == "confirmed", do: "Rendez-vous confirmé", else: "Rendez-vous refusé"
    message = if status == "confirmed" do
      "Votre rendez-vous du #{format_datetime(appointment.scheduled_at)} a été confirmé par Dr. #{doctor.first_name} #{doctor.last_name}"
    else
      "Votre rendez-vous du #{format_datetime(appointment.scheduled_at)} a été refusé par Dr. #{doctor.first_name} #{doctor.last_name}"
    end
    Telemed.Notifications.create_notification(%{
      user_id: appointment.patient_id,
      title: titre,
      message: message,
      type: if(status == "confirmed", do: "appointment_confirmed", else: "appointment_rejected"),
      appointment_id: appointment.id,
      read: false
    })
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y à %H:%M")
  end


end
