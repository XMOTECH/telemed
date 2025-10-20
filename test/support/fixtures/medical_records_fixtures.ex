defmodule Telemed.MedicalRecordsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Telemed.MedicalRecords` context.
  """

  import Telemed.AccountsFixtures

  @doc """
  Generate a medical_record.
  """
  def medical_record_fixture(attrs \\ %{}) do
    # Créer un patient et un docteur si nécessaires
    patient = user_fixture(%{role: "patient"})
    doctor = user_fixture(%{role: "doctor"})

    {:ok, medical_record} =
      attrs
      |> Enum.into(%{
        age: 42,
        description: "some description",
        nom: "some nom",
        user_id: patient.id,
        doctor_id: doctor.id,
        record_type: "general",
        status: "active"
      })
      |> Telemed.MedicalRecords.create_medical_record()

    medical_record
  end
end
