defmodule Telemed.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Telemed.Repo
  alias Telemed.Notification

  @doc """
  Returns the list of notifications for a user.
  """
  def list_user_notifications(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> order_by([n], [desc: n.inserted_at])
    |> Repo.all()
  end

  @doc """
  Returns the list of notifications for a user (alias for list_user_notifications).
  """
  def list_notifications_for_user(user_id) do
    list_user_notifications(user_id)
  end

  @doc """
  Returns unread notifications count for a user.
  """
  def unread_notifications_count(user_id) do
    Notification
    |> where(user_id: ^user_id, read: false)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets a single notification.
  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Gets a single notification (retourne nil si not found)
  """
  def get_notification(id), do: Repo.get(Notification, id)

  @doc """
  Creates a notification.
  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.
  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.
  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Marks a notification as read.
  """
  def mark_as_read(%Notification{} = notification) do
    update_notification(notification, %{read: true})
  end

  @doc """
  Marks all notifications as read for a user.
  """
  def mark_all_as_read(user_id) do
    Notification
    |> where(user_id: ^user_id, read: false)
    |> Repo.update_all(set: [read: true])
  end

  @doc """
  Marks all notifications as read for a user (alias for mark_all_as_read).
  """
  def mark_all_as_read_for_user(user_id) do
    mark_all_as_read(user_id)
  end

  @doc """
  Gets notification by appointment and type.
  """
  def get_notification_by_appointment_and_type(appointment_id, type) do
    Notification
    |> where(appointment_id: ^appointment_id, type: ^type)
    |> Repo.one()
  end

  @doc """
  Gets notifications by type for a user.
  """
  def get_notifications_by_type(user_id, type) do
    Notification
    |> where(user_id: ^user_id, type: ^type)
    |> order_by([n], [desc: n.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets recent notifications for a user (last 10).
  """
  def get_recent_notifications(user_id, limit \\ 10) do
    Notification
    |> where(user_id: ^user_id)
    |> order_by([n], [desc: n.inserted_at])
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Creates an appointment notification for the doctor.
  """
  def create_appointment_notification(appointment) do
    message = "Nouveau rendez-vous demandé par #{appointment.patient.first_name} #{appointment.patient.last_name} pour le #{format_datetime(appointment.scheduled_at)}"

    create_notification(%{
      user_id: appointment.doctor_id,
      appointment_id: appointment.id,
      message: message,
      type: "appointment_request",
      read: false
    })
  end

  @doc """
  Creates an appointment confirmation notification for the patient.
  """
  def create_confirmation_notification(appointment) do
    message = "Votre rendez-vous avec Dr. #{appointment.doctor.first_name} #{appointment.doctor.last_name} a été confirmé pour le #{format_datetime(appointment.scheduled_at)}"

    create_notification(%{
      user_id: appointment.patient_id,
      appointment_id: appointment.id,
      message: message,
      type: "appointment_confirmed",
      read: false
    })
  end

  @doc """
  Creates a consultation notification.
  """
  def create_consultation_notification(appointment_id, user_id, message, type) do
    create_notification(%{
      user_id: user_id,
      appointment_id: appointment_id,
      title: "Consultation",
      message: message,
      type: type,
      read: false
    })
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y à %H:%M")
  end
end
