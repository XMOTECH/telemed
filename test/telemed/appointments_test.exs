defmodule Telemed.AppointmentsTest do
  use Telemed.DataCase

  alias Telemed.{Appointments, Accounts}

  describe "appointments CRUD" do
    setup do
      # Créer des utilisateurs
      {:ok, doctor} = Accounts.register_user(%{
        email: "appt_doctor_#{:rand.uniform(10000)}@test.com",
        password: "Password123!",
        role: "doctor",
        first_name: "Appt",
        last_name: "Doctor"
      })

      {:ok, patient} = Accounts.register_user(%{
        email: "appt_patient_#{:rand.uniform(10000)}@test.com",
        password: "Password123!",
        role: "patient",
        first_name: "Appt",
        last_name: "Patient"
      })

      %{doctor: doctor, patient: patient}
    end

    test "crée un rendez-vous", %{doctor: doctor, patient: patient} do
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      attrs = %{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        notes: "Test consultation",
        status: "pending"
      }

      {:ok, appointment} = Appointments.create_appointment(attrs)

      assert appointment.patient_id == patient.id
      assert appointment.doctor_id == doctor.id
      assert appointment.status == "pending"
      assert appointment.notes == "Test consultation"
    end

    test "liste les rendez-vous d'un patient", %{doctor: doctor, patient: patient} do
      # Créer plusieurs RDV
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      {:ok, _appt1} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        status: "pending"
      })

      {:ok, _appt2} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: DateTime.add(scheduled_at, 7200, :second),
        status: "confirmed"
      })

      appointments = Appointments.list_patient_appointments(patient.id)

      assert length(appointments) >= 2
      assert Enum.all?(appointments, fn appt -> appt.patient_id == patient.id end)
    end

    test "liste les rendez-vous d'un docteur", %{doctor: doctor, patient: patient} do
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      {:ok, _appt} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        status: "pending"
      })

      appointments = Appointments.list_doctor_appointments(doctor.id)

      assert length(appointments) >= 1
      assert Enum.all?(appointments, fn appt -> appt.doctor_id == doctor.id end)
    end

    test "récupère un rendez-vous par ID", %{doctor: doctor, patient: patient} do
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      {:ok, created_appt} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        status: "pending"
      })

      fetched_appt = Appointments.get_appointment!(created_appt.id)

      assert fetched_appt.id == created_appt.id
      assert fetched_appt.patient_id == patient.id
      assert fetched_appt.doctor_id == doctor.id
    end

    test "met à jour un rendez-vous", %{doctor: doctor, patient: patient} do
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      {:ok, appointment} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        status: "pending"
      })

      {:ok, updated_appt} = Appointments.update_appointment(appointment, %{
        status: "confirmed",
        notes: "Updated notes"
      })

      assert updated_appt.status == "confirmed"
      assert updated_appt.notes == "Updated notes"
    end

    test "supprime un rendez-vous", %{doctor: doctor, patient: patient} do
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      {:ok, appointment} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        status: "pending"
      })

      assert {:ok, _deleted} = Appointments.delete_appointment(appointment)
      assert_raise Ecto.NoResultsError, fn ->
        Appointments.get_appointment!(appointment.id)
      end
    end

    test "valide les champs requis", %{doctor: doctor} do
      # Manque patient_id
      assert {:error, changeset} = Appointments.create_appointment(%{
        doctor_id: doctor.id,
        scheduled_at: DateTime.utc_now()
      })

      assert length(changeset.errors) > 0
    end

    test "change le statut en confirmed", %{doctor: doctor, patient: patient} do
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      {:ok, appointment} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        status: "pending"
      })

      {:ok, confirmed} = Appointments.update_appointment(appointment, %{status: "confirmed"})

      assert confirmed.status == "confirmed"
    end

    test "change le statut en cancelled", %{doctor: doctor, patient: patient} do
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      {:ok, appointment} = Appointments.create_appointment(%{
        patient_id: patient.id,
        doctor_id: doctor.id,
        scheduled_at: scheduled_at,
        status: "pending"
      })

      {:ok, cancelled} = Appointments.update_appointment(appointment, %{status: "cancelled"})

      assert cancelled.status == "cancelled"
    end
  end
end
