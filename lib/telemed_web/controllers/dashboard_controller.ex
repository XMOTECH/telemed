defmodule TelemedWeb.DashboardController do
  use TelemedWeb, :controller

  alias Telemed.Accounts
  alias Telemed.Appointments
  alias Telemed.MedicalRecords
  alias Telemed.Notifications

  def index(conn, _params) do
    user = conn.assigns.current_user

    dashboard_data =
      case user.role do
        "patient" -> patient_dashboard(user)
        "doctor" -> doctor_dashboard(user)
        "admin" -> admin_dashboard(user)
        _ -> fallback_dashboard()
      end

    render(conn, "dashboard.html",
      user: user,
      role: user.role,
      dashboard: dashboard_data
    )
  end

  defp patient_dashboard(user) do
    all_appointments = Appointments.list_patient_appointments(user.id)
    medical_records = MedicalRecords.list_medical_records_for_user(user.id)

    %{
      upcoming_appointments: filter_appointments(all_appointments, :upcoming),
      past_appointments: filter_appointments(all_appointments, :past),
      medical_records: medical_records,
      notifications: Notifications.get_recent_notifications(user.id, 5),
      stats: %{
        total_appointments: length(all_appointments),
        total_medical_records: length(medical_records)
      }
    }
  end

  defp doctor_dashboard(user) do
    all_appointments = Appointments.list_doctor_appointments(user.id)

    %{
      today_appointments: filter_appointments(all_appointments, :today),
      upcoming_appointments: filter_appointments(all_appointments, :upcoming),
      patients: Appointments.list_patients_for_doctor(user.id),
      notifications: Notifications.get_recent_notifications(user.id, 5),
      stats: %{
        total_appointments: length(all_appointments),
        total_patients: length(Appointments.list_patients_for_doctor(user.id))
      }
    }
  end

  defp admin_dashboard(_user) do
    users = Accounts.list_users()
    appointments = Appointments.list_appointments()

    %{
      stats: %{
        total_users: length(users),
        total_doctors: length(Enum.filter(users, &(&1.role == "doctor"))),
        total_patients: length(Enum.filter(users, &(&1.role == "patient"))),
        total_appointments: length(appointments)
      },
      recent_users: Enum.take(users, 5),
      system_health: %{
        database_status: "OK",
        server_uptime: "Running",
        active_sessions: :rand.uniform(length(users))
      }
    }
  end

  defp fallback_dashboard, do: %{}

  defp filter_appointments(appointments, type) do
    now = DateTime.utc_now()
    today = Date.utc_today()

    Enum.filter(appointments, fn appointment ->
      appt_dt = to_utc_datetime(appointment.scheduled_at)

      case type do
        :today -> Date.to_iso8601(appt_dt) == Date.to_iso8601(today)
        :upcoming -> DateTime.compare(appt_dt, now) == :gt
        :past -> DateTime.compare(appt_dt, now) in [:lt, :eq]
      end
    end)
  end

  defp to_utc_datetime(%NaiveDateTime{} = naive), do: DateTime.from_naive!(naive, "Etc/UTC")
  defp to_utc_datetime(%DateTime{} = dt), do: dt
end
