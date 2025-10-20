defmodule TelemedWeb.AppointmentHTML do
  use TelemedWeb, :html

  embed_templates "appointment_html/*"

  alias Telemed.Accounts

  @doc """
  Renders a appointment form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def appointment_form(assigns)

  def get_specialty(email) do
    cond do
      String.contains?(email, "cardio") -> "Cardiologie"
      String.contains?(email, "pediatrie") -> "Pédiatrie"
      String.contains?(email, "dermatologie") -> "Dermatologie"
      String.contains?(email, "psychiatrie") -> "Psychiatrie"
      String.contains?(email, "gynecologie") -> "Gynécologie"
      true -> "Médecine générale"
    end
  end

  def status_label(status) do
    case status do
      "pending" -> "En attente"
      "confirmed" -> "Confirmé"
      "rejected" -> "Refusé"
      "cancelled" -> "Annulé"
      "completed" -> "Terminé"
      _ -> status
    end
  end

  def status_class(status) do
    base_classes = "px-2 py-1 rounded-full text-xs font-medium"

    case status do
      "pending" -> "#{base_classes} bg-yellow-100 text-yellow-800"
      "confirmed" -> "#{base_classes} bg-green-100 text-green-800"
      "rejected" -> "#{base_classes} bg-red-100 text-red-800"
      "cancelled" -> "#{base_classes} bg-gray-100 text-gray-800"
      "completed" -> "#{base_classes} bg-blue-100 text-blue-800"
      _ -> "#{base_classes} bg-gray-100 text-gray-800"
    end
  end

  def status_badge_class(status) do
    case status do
      "pending" -> "bg-yellow-100 text-yellow-800"
      "confirmed" -> "bg-green-100 text-green-800"
      "rejected" -> "bg-red-100 text-red-800"
      "cancelled" -> "bg-gray-100 text-gray-800"
      "completed" -> "bg-blue-100 text-blue-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def get_doctor_name(doctor_id) do
    case Accounts.get_user!(doctor_id) do
      nil -> "Médecin inconnu"
      doctor -> "Dr. #{doctor.first_name} #{doctor.last_name}"
    end
  end

  def get_patient_name(patient_id) do
    case Accounts.get_user!(patient_id) do
      nil -> "Patient inconnu"
      patient -> "#{patient.first_name} #{patient.last_name}"
    end
  end

  def should_show_validation_buttons?(appointment) do
    # Afficher les boutons seulement si le rendez-vous est en attente
    appointment.status == "pending"
  end
end
