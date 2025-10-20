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
    # Gérer les tags (convertir JSON string en array)
    params = parse_tags(medical_record_params)

    # Assigner automatiquement user_id et doctor_id depuis l'utilisateur connecté
    params = params
      |> Map.put("user_id", conn.assigns.current_user.id)
      |> Map.put("doctor_id", conn.assigns.current_user.id)

    case MedicalRecords.create_medical_record(params) do
      {:ok, medical_record} ->
        conn
        |> put_flash(:info, "✅ Dossier médical créé avec succès !")
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

    # Gérer les tags
    params = parse_tags(medical_record_params)

    # Assigner automatiquement last_modified_by_id
    params = Map.put(params, "last_modified_by_id", conn.assigns.current_user.id)

    case MedicalRecords.update_medical_record(medical_record, params) do
      {:ok, medical_record} ->
        conn
        |> put_flash(:info, "✅ Dossier médical mis à jour avec succès !")
        |> redirect(to: ~p"/medical_records/#{medical_record}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, medical_record: medical_record, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    medical_record = MedicalRecords.get_medical_record!(id)
    {:ok, _medical_record} = MedicalRecords.delete_medical_record(medical_record)

    conn
    |> put_flash(:info, "🗑️ Dossier médical supprimé avec succès.")
    |> redirect(to: ~p"/medical_records")
  end

  # Helper pour parser les tags depuis le formulaire
  defp parse_tags(params) do
    case params["tags"] do
      [json_string] when is_binary(json_string) ->
        case Jason.decode(json_string) do
          {:ok, tags} when is_list(tags) ->
            Map.put(params, "tags", tags)
          _ ->
            params
        end
      _ ->
        params
    end
  end
end
