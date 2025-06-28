defmodule Telemed.MedicalRecords do
  @moduledoc """
  The MedicalRecords context.
  """

  import Ecto.Query, warn: false
  alias Telemed.Repo

  alias Telemed.MedicalRecords.MedicalRecord

  @doc """
  Returns the list of medical_records.

  ## Examples

      iex> list_medical_records()
      [%MedicalRecord{}, ...]

  """
  def list_medical_records do
    Repo.all(MedicalRecord)
  end

  @doc """
  Gets a single medical_record.

  Raises `Ecto.NoResultsError` if the Medical record does not exist.

  ## Examples

      iex> get_medical_record!(123)
      %MedicalRecord{}

      iex> get_medical_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_medical_record!(id), do: Repo.get!(MedicalRecord, id)

  @doc """
  Creates a medical_record.

  ## Examples

      iex> create_medical_record(%{field: value})
      {:ok, %MedicalRecord{}}

      iex> create_medical_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_medical_record(attrs \\ %{}) do
    %MedicalRecord{}
    |> MedicalRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a medical_record.

  ## Examples

      iex> update_medical_record(medical_record, %{field: new_value})
      {:ok, %MedicalRecord{}}

      iex> update_medical_record(medical_record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_medical_record(%MedicalRecord{} = medical_record, attrs) do
    medical_record
    |> MedicalRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a medical_record.

  ## Examples

      iex> delete_medical_record(medical_record)
      {:ok, %MedicalRecord{}}

      iex> delete_medical_record(medical_record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_medical_record(%MedicalRecord{} = medical_record) do
    Repo.delete(medical_record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking medical_record changes.

  ## Examples

      iex> change_medical_record(medical_record)
      %Ecto.Changeset{data: %MedicalRecord{}}

  """
  def change_medical_record(%MedicalRecord{} = medical_record, attrs \\ %{}) do
    MedicalRecord.changeset(medical_record, attrs)
  end
end
