defmodule TelemedWeb.MedicalRecordHTML do
  use TelemedWeb, :html

  embed_templates "medical_record_html/*"

  @doc """
  Renders a medical_record form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def medical_record_form(assigns)

  @doc """
  Vérifie si un dossier médical contient des données SOAP
  """
  def has_soap_data?(record) do
    record.soap_subjective || record.soap_objective ||
    record.soap_assessment || record.soap_plan
  end
end
