defmodule Telemed.Repo.Migrations.FixLastModifiedByColumnName do
  use Ecto.Migration

  def change do
    # Renommer la colonne pour respecter la convention Ecto
    # Ecto s'attend à "last_modified_by_id" pour belongs_to :last_modified_by
    rename table(:medical_records), :last_modified_by, to: :last_modified_by_id
  end
end
