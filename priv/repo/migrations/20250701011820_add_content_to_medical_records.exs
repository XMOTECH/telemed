defmodule Telemed.Repo.Migrations.AddContentToMedicalRecords do
  use Ecto.Migration

  def change do
    alter table(:medical_records) do
      add :content, :text
    end
  end
end
