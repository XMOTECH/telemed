defmodule TelemedWeb.MedicalRecordController do
  use TelemedWeb, :controller

  alias Telemed.MedicalRecords
  alias Telemed.MedicalRecords.MedicalRecord

  def index(conn, _params) do
    medical_records = MedicalRecords.list_medical_records()
    render(conn, :index, medical_records: medical_records)
  end

  def new(conn, _params) do
    changeset = MedicalRecords.change_medical_record(%MedicalRecord{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"medical_record" => medical_record_params}) do
    case MedicalRecords.create_medical_record(medical_record_params) do
      {:ok, medical_record} ->
        conn
        |> put_flash(:info, "Medical record created successfully.")
        |> redirect(to: ~p"/medical_records/#{medical_record}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    medical_record = MedicalRecords.get_medical_record!(id)
    render(conn, :show, medical_record: medical_record)
  end

  def edit(conn, %{"id" => id}) do
    medical_record = MedicalRecords.get_medical_record!(id)
    changeset = MedicalRecords.change_medical_record(medical_record)
    render(conn, :edit, medical_record: medical_record, changeset: changeset)
  end

  def update(conn, %{"id" => id, "medical_record" => medical_record_params}) do
    medical_record = MedicalRecords.get_medical_record!(id)

    case MedicalRecords.update_medical_record(medical_record, medical_record_params) do
      {:ok, medical_record} ->
        conn
        |> put_flash(:info, "Medical record updated successfully.")
        |> redirect(to: ~p"/medical_records/#{medical_record}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, medical_record: medical_record, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    medical_record = MedicalRecords.get_medical_record!(id)
    {:ok, _medical_record} = MedicalRecords.delete_medical_record(medical_record)

    conn
    |> put_flash(:info, "Medical record deleted successfully.")
    |> redirect(to: ~p"/medical_records")
  end
end
