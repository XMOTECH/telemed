defmodule Telemed.Appointments do
  @moduledoc """
  The Appointments context.
  """

  import Ecto.Query, warn: false
  alias Telemed.Repo
  alias Telemed.Appointment
  alias Telemed.Accounts.User

  @doc """
  Returns the list of appointments.

  ## Examples

      iex> list_appointments()
      [%Appointment{}, ...]

  """
  def list_appointments do
    Repo.all(Appointment)
  end

  @doc """
  Returns the list of appointments for a specific doctor.
  """
  def list_doctor_appointments(doctor_id) do
    Appointment
    |> where(doctor_id: ^doctor_id)
    |> order_by([a], [desc: a.scheduled_at])
    |> preload([:patient, :doctor])
    |> Repo.all()
  end

  @doc """
  Returns the list of appointments for a specific patient.
  """
  def list_patient_appointments(patient_id) do
    Appointment
    |> where(patient_id: ^patient_id)
    |> order_by([a], [desc: a.scheduled_at])
    |> preload([:patient, :doctor])
    |> Repo.all()
  end

  @doc """
  Returns the list of unique patients for a doctor.
  """
  def list_patients_for_doctor(doctor_id) do
    patient_ids_query =
      from a in Appointment,
      where: a.doctor_id == ^doctor_id,
      select: a.patient_id,
      distinct: true

    patient_ids = Repo.all(patient_ids_query)

    query = from u in User,
      where: u.id in ^patient_ids,
      select: u

    Repo.all(query)
  end

  @doc """
  Returns the list of appointments for today.
  """
  def list_today_appointments(user_id, user_role) do
    today = Date.utc_today()

    query = case user_role do
      "doctor" ->
        Appointment
        |> where(doctor_id: ^user_id)
        |> where(fragment("DATE(scheduled_at) = ?", ^Date.to_string(today)))
        |> where(status: "confirmed")
        |> order_by([a], a.scheduled_at)
        |> preload([:patient, :doctor])

      "patient" ->
        Appointment
        |> where(patient_id: ^user_id)
        |> where(fragment("DATE(scheduled_at) = ?", ^Date.to_string(today)))
        |> where(status: "confirmed")
        |> order_by([a], a.scheduled_at)
        |> preload([:patient, :doctor])

      _ ->
        Appointment
        |> where(fragment("DATE(scheduled_at) = ?", ^Date.to_string(today)))
        |> where(status: "confirmed")
        |> order_by([a], a.scheduled_at)
        |> preload([:patient, :doctor])
    end

    Repo.all(query)
  end

  @doc """
  Returns appointments that need reminders (5 minutes before).
  """
  def list_appointments_for_reminders(start_time, end_time) do
    Appointment
    |> where([a], a.scheduled_at >= ^start_time and a.scheduled_at <= ^end_time)
    |> where(status: "confirmed")
    |> preload([:patient, :doctor])
    |> Repo.all()
  end

  @doc """
  Gets a single appointment with preloaded associations.
  """
  def get_appointment_with_associations!(id) do
    Appointment
    |> where(id: ^id)
    |> preload([:patient, :doctor])
    |> Repo.one!()
  end

  @doc """
  Gets a single appointment.

  Raises `Ecto.NoResultsError` if the Appointment does not exist.

  ## Examples

      iex> get_appointment!(123)
      %Appointment{}

      iex> get_appointment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_appointment!(id), do: Repo.get!(Appointment, id) |> Repo.preload([:patient, :doctor])

  @doc """
  Gets a single appointment (retourne {:ok, appointment} ou {:error, :not_found})
  """
  def get_appointment(id) do
    case Repo.get(Appointment, id) do
      nil -> {:error, :not_found}
      appointment -> {:ok, Repo.preload(appointment, [:patient, :doctor])}
    end
  end

  @doc """
  Creates a appointment.

  ## Examples

      iex> create_appointment(%{field: value})
      {:ok, %Appointment{}}

      iex> create_appointment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_appointment(attrs \\ %{}) do
    %Appointment{}
    |> Appointment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a appointment.

  ## Examples

      iex> update_appointment(appointment, %{field: new_value})
      {:ok, %Appointment{}}

      iex> update_appointment(appointment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_appointment(%Appointment{} = appointment, attrs) do
    appointment
    |> Appointment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a appointment.

  ## Examples

      iex> delete_appointment(appointment)
      {:ok, %Appointment{}}

      iex> delete_appointment(appointment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_appointment(%Appointment{} = appointment) do
    Repo.delete(appointment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking appointment changes.

  ## Examples

      iex> change_appointment(appointment)
      %Ecto.Changeset{data: %Appointment{}}

  """
  def change_appointment(%Appointment{} = appointment, attrs \\ %{}) do
    Appointment.changeset(appointment, attrs)
  end

  @doc """
  Gets available time slots for a doctor on a specific date.
  """
  def get_available_slots(doctor_id, date) do
    start_time = NaiveDateTime.new!(date, ~T[09:00:00])
    end_time = NaiveDateTime.new!(date, ~T[17:00:00])

    existing_appointments =
      from a in Appointment,
      where: a.doctor_id == ^doctor_id,
      where: fragment("date(?)", a.scheduled_at) == ^date,
      select: a.scheduled_at

    booked_slots = Repo.all(existing_appointments)

    all_slots =
      Stream.iterate(start_time, &NaiveDateTime.add(&1, 30 * 60))
      |> Stream.take_while(&NaiveDateTime.compare(&1, end_time) == :lt)
      |> Enum.to_list()

    Enum.reject(all_slots, &(&1 in booked_slots))
  end
end
