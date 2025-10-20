defmodule Telemed.Repo.Migrations.AddDiagnosisAndTreatmentPlanToMedicalRecords do
  use Ecto.Migration

  def change do
    alter table(:medical_records) do
      add :diagnosis, :text
      add :treatment_plan, :text
    end
  end
end
