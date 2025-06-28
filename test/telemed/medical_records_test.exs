defmodule Telemed.MedicalRecordsTest do
  use Telemed.DataCase

  alias Telemed.MedicalRecords

  describe "medical_records" do
    alias Telemed.MedicalRecords.MedicalRecord

    import Telemed.MedicalRecordsFixtures

    @invalid_attrs %{description: nil, nom: nil, age: nil}

    test "list_medical_records/0 returns all medical_records" do
      medical_record = medical_record_fixture()
      assert MedicalRecords.list_medical_records() == [medical_record]
    end

    test "get_medical_record!/1 returns the medical_record with given id" do
      medical_record = medical_record_fixture()
      assert MedicalRecords.get_medical_record!(medical_record.id) == medical_record
    end

    test "create_medical_record/1 with valid data creates a medical_record" do
      valid_attrs = %{description: "some description", nom: "some nom", age: 42}

      assert {:ok, %MedicalRecord{} = medical_record} = MedicalRecords.create_medical_record(valid_attrs)
      assert medical_record.description == "some description"
      assert medical_record.nom == "some nom"
      assert medical_record.age == 42
    end

    test "create_medical_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MedicalRecords.create_medical_record(@invalid_attrs)
    end

    test "update_medical_record/2 with valid data updates the medical_record" do
      medical_record = medical_record_fixture()
      update_attrs = %{description: "some updated description", nom: "some updated nom", age: 43}

      assert {:ok, %MedicalRecord{} = medical_record} = MedicalRecords.update_medical_record(medical_record, update_attrs)
      assert medical_record.description == "some updated description"
      assert medical_record.nom == "some updated nom"
      assert medical_record.age == 43
    end

    test "update_medical_record/2 with invalid data returns error changeset" do
      medical_record = medical_record_fixture()
      assert {:error, %Ecto.Changeset{}} = MedicalRecords.update_medical_record(medical_record, @invalid_attrs)
      assert medical_record == MedicalRecords.get_medical_record!(medical_record.id)
    end

    test "delete_medical_record/1 deletes the medical_record" do
      medical_record = medical_record_fixture()
      assert {:ok, %MedicalRecord{}} = MedicalRecords.delete_medical_record(medical_record)
      assert_raise Ecto.NoResultsError, fn -> MedicalRecords.get_medical_record!(medical_record.id) end
    end

    test "change_medical_record/1 returns a medical_record changeset" do
      medical_record = medical_record_fixture()
      assert %Ecto.Changeset{} = MedicalRecords.change_medical_record(medical_record)
    end
  end
end
