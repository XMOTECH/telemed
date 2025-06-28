defmodule Telemed.MedicalRecordsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Telemed.MedicalRecords` context.
  """

  @doc """
  Generate a medical_record.
  """
  def medical_record_fixture(attrs \\ %{}) do
    {:ok, medical_record} =
      attrs
      |> Enum.into(%{
        age: 42,
        description: "some description",
        nom: "some nom"
      })
      |> Telemed.MedicalRecords.create_medical_record()

    medical_record
  end
end
