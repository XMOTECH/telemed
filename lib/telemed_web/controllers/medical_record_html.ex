defmodule TelemedWeb.MedicalRecordHTML do
  use TelemedWeb, :html

  embed_templates "medical_record_html/*"

  @doc """
  Renders a medical_record form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def medical_record_form(assigns)
end
