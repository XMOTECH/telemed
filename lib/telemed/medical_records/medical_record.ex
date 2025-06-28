defmodule Telemed.MedicalRecords.MedicalRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "medical_records" do
    field :description, :string
    field :nom, :string
    field :age, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(medical_record, attrs) do
    medical_record
    |> cast(attrs, [:nom, :age, :description])
    |> validate_required([:nom, :age, :description])
  end
end
