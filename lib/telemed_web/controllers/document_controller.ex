defmodule TelemedWeb.DocumentController do
  use TelemedWeb, :controller

  require Logger
  alias Telemed.{Documents, MedicalRecords}

  @doc """
  Liste les documents d'un dossier médical.
  """
  def index(conn, %{"medical_record_id" => medical_record_id}) do
    medical_record = MedicalRecords.get_medical_record!(medical_record_id)
    documents = Documents.list_documents(medical_record_id)

    render(conn, :index,
      medical_record: medical_record,
      documents: documents
    )
  end

  @doc """
  Formulaire d'upload.
  """
  def new(conn, %{"medical_record_id" => medical_record_id}) do
    medical_record = MedicalRecords.get_medical_record!(medical_record_id)

    render(conn, :new,
      medical_record: medical_record,
      document_types: Telemed.Documents.MedicalDocument.document_types()
    )
  end

  @doc """
  Upload un document.
  """
  def create(conn, %{"medical_record_id" => medical_record_id, "document" => document_params}) do
    current_user = conn.assigns.current_user
    upload = document_params["file"]

    if upload do
      case Documents.validate_upload(upload) do
        :ok ->
          attrs = %{
            document_type: document_params["document_type"] || "other",
            description: document_params["description"]
          }

          case Documents.upload_document(upload, medical_record_id, current_user.id, attrs) do
            {:ok, document} ->
              conn
              |> put_flash(:info, "✅ Document uploadé avec succès: #{document.filename}")
              |> redirect(to: ~p"/medical_records/#{medical_record_id}")

            {:error, reason} ->
              conn
              |> put_flash(:error, "Erreur upload: #{inspect(reason)}")
              |> redirect(to: ~p"/medical_records/#{medical_record_id}/documents/new")
          end

        {:error, message} ->
          conn
          |> put_flash(:error, message)
          |> redirect(to: ~p"/medical_records/#{medical_record_id}/documents/new")
      end
    else
      conn
      |> put_flash(:error, "Aucun fichier sélectionné")
      |> redirect(to: ~p"/medical_records/#{medical_record_id}/documents/new")
    end
  end

  @doc """
  Affiche un document.
  """
  def show(conn, %{"id" => id}) do
    document = Documents.get_document!(id)

    render(conn, :show, document: document)
  end

  @doc """
  Télécharge un fichier.
  """
  def download(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    current_user = conn.assigns.current_user

    # Vérifier les permissions
    if can_access_document?(current_user, document) do
      if File.exists?(document.file_path) do
        conn
        |> put_resp_content_type(document.content_type || "application/octet-stream")
        |> put_resp_header("content-disposition", "attachment; filename=\"#{document.filename}\"")
        |> send_file(200, document.file_path)
      else
        conn
        |> put_flash(:error, "Fichier introuvable")
        |> redirect(to: ~p"/medical_records")
      end
    else
      conn
      |> put_flash(:error, "Vous n'êtes pas autorisé à accéder à ce document")
      |> redirect(to: ~p"/dashboard")
    end
  end

  @doc """
  Supprime un document.
  """
  def delete(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    current_user = conn.assigns.current_user

    # Seul l'uploader ou un admin peut supprimer
    if current_user.id == document.uploaded_by_id or current_user.role == "admin" do
      case Documents.delete_document(document) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Document supprimé")
          |> redirect(to: ~p"/medical_records/#{document.medical_record_id}")

        {:error, _} ->
          conn
          |> put_flash(:error, "Erreur suppression")
          |> redirect(to: ~p"/medical_records/#{document.medical_record_id}")
      end
    else
      conn
      |> put_flash(:error, "Non autorisé")
      |> redirect(to: ~p"/dashboard")
    end
  end

  # ========== HELPERS ==========

  defp can_access_document?(user, document) do
    cond do
      user.role == "admin" -> true
      user.id == document.uploaded_by_id -> true
      user.id == document.medical_record.user_id -> true
      user.id == document.medical_record.doctor_id -> true
      true -> false
    end
  end
end
