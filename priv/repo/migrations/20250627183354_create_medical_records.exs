defmodule Telemed.Repo.Migrations.CreateMedicalRecords do
  use Ecto.Migration

  def change do
    create table(:medical_records) do
      add :nom, :string
      add :age, :integer
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
