defmodule TelemedWeb.DocumentHTML do
  use TelemedWeb, :html

  embed_templates "document_html/*"

  @doc "Icône selon le type de document"
  def document_icon(content_type) do
    cond do
      String.contains?(content_type || "", "pdf") -> "📄"
      String.contains?(content_type || "", "image") -> "🖼️"
      String.contains?(content_type || "", "word") -> "📝"
      true -> "📎"
    end
  end

  @doc "Formatte la taille de fichier"
  def format_file_size(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_000_000 -> "#{Float.round(bytes / 1_000_000, 1)} MB"
      bytes >= 1_000 -> "#{Float.round(bytes / 1_000, 1)} KB"
      true -> "#{bytes} B"
    end
  end
  def format_file_size(_), do: "N/A"
end
