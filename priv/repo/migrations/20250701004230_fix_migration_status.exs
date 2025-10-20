defmodule Telemed.Repo.Migrations.FixMigrationStatus do
  use Ecto.Migration

  def up do
    # Force l'enregistrement de toutes les migrations existantes
    execute "INSERT INTO schema_migrations (version, inserted_at) VALUES ('20250627183055', NOW()) ON CONFLICT (version) DO NOTHING"
    execute "INSERT INTO schema_migrations (version, inserted_at) VALUES ('20250627183354', NOW()) ON CONFLICT (version) DO NOTHING"
    execute "INSERT INTO schema_migrations (version, inserted_at) VALUES ('20250629023829', NOW()) ON CONFLICT (version) DO NOTHING"
    execute "INSERT INTO schema_migrations (version, inserted_at) VALUES ('20250629025226', NOW()) ON CONFLICT (version) DO NOTHING"
    execute "INSERT INTO schema_migrations (version, inserted_at) VALUES ('20250629032058', NOW()) ON CONFLICT (version) DO NOTHING"
    execute "INSERT INTO schema_migrations (version, inserted_at) VALUES ('20250629230819', NOW()) ON CONFLICT (version) DO NOTHING"
    execute "INSERT INTO schema_migrations (version, inserted_at) VALUES ('20250701001314', NOW()) ON CONFLICT (version) DO NOTHING"
  end

  def down do
    # Ne rien faire en cas de rollback
  end
end
