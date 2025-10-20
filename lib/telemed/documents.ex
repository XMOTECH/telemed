defmodule Telemed.Documents do
  @moduledoc """
  Contexte pour gérer les documents médicaux.

  Gère l'upload, le stockage et la récupération de fichiers médicaux
  associés aux dossiers médicaux électroniques (DME).
  """

  import Ecto.Query
  require Logger

  alias Telemed.Repo
  alias Telemed.Documents.MedicalDocument

  @upload_dir "priv/static/uploads/medical_documents"

  @doc """
  Liste tous les documents d'un dossier médical.
  """
  def list_documents(medical_record_id) do
    MedicalDocument
    |> where([d], d.medical_record_id == ^medical_record_id)
    |> order_by([d], desc: d.inserted_at)
    |> Repo.all()
    |> Repo.preload([:uploaded_by])
  end

  @doc """
  Récupère un document par son ID.
  """
  def get_document!(id) do
    Repo.get!(MedicalDocument, id)
    |> Repo.preload([:medical_record, :uploaded_by])
  end

  @doc """
  Upload un fichier et crée l'entrée en base de données.

  ## Exemples

      iex> upload_document(%Plug.Upload{}, medical_record_id, user_id, %{document_type: "prescription"})
      {:ok, %MedicalDocument{}}
  """
  def upload_document(upload, medical_record_id, uploaded_by_id, attrs \\ %{}) do
    with {:ok, file_path} <- save_file(upload),
         {:ok, document} <- create_document_record(upload, file_path, medical_record_id, uploaded_by_id, attrs) do
      {:ok, document}
    else
      {:error, reason} = error ->
        Logger.error("Failed to upload document: #{inspect(reason)}")
        error
    end
  end

  @doc """
  Supprime un document (fichier + entrée DB).
  """
  def delete_document(%MedicalDocument{} = document) do
    # Supprimer le fichier physique
    if File.exists?(document.file_path) do
      File.rm(document.file_path)
    end

    # Supprimer l'entrée DB
    Repo.delete(document)
  end

  @doc """
  Vérifie si un fichier est autorisé (extension, taille).
  """
  def validate_upload(upload) do
    cond do
      upload.content_type not in allowed_content_types() ->
        {:error, "Type de fichier non autorisé"}

      upload.size > MedicalDocument.max_file_size() ->
        {:error, "Fichier trop volumineux (max 50MB)"}

      not valid_extension?(upload.filename) ->
        {:error, "Extension de fichier non autorisée"}

      true ->
        :ok
    end
  end

  # ========== PRIVATE FUNCTIONS ==========

  defp save_file(upload) do
    # Créer le dossier si nécessaire
    File.mkdir_p!(@upload_dir)

    # Générer un nom unique
    extension = Path.extname(upload.filename)
    unique_filename = "#{:erlang.unique_integer([:positive])}#{extension}"
    destination = Path.join(@upload_dir, unique_filename)

    # Copier le fichier
    case File.cp(upload.path, destination) do
      :ok ->
        {:ok, destination}

      {:error, reason} ->
        {:error, "Échec sauvegarde fichier: #{inspect(reason)}"}
    end
  end

  defp create_document_record(upload, file_path, medical_record_id, uploaded_by_id, attrs) do
    document_attrs = %{
      filename: upload.filename,
      file_path: file_path,
      content_type: upload.content_type,
      file_size: upload.size,
      medical_record_id: medical_record_id,
      uploaded_by_id: uploaded_by_id
    }
    |> Map.merge(attrs)

    %MedicalDocument{}
    |> MedicalDocument.changeset(document_attrs)
    |> Repo.insert()
  end

  defp allowed_content_types do
    [
      "application/pdf",
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/gif",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "text/plain"
    ]
  end

  defp valid_extension?(filename) do
    extension = Path.extname(filename) |> String.downcase()
    extension in MedicalDocument.allowed_extensions()
  end
end
