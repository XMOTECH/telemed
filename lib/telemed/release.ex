defmodule Telemed.Release do
  @moduledoc """
  Tasks de déploiement et maintenance pour la production.

  Utilisé pour exécuter des tâches lors du déploiement comme :
  - Migrations de base de données
  - Création de comptes admin
  - Rollback de migrations
  """

  @app :telemed

  @doc """
  Exécute toutes les migrations en attente.

  Utilisé lors du déploiement :
  ```
  /app/bin/telemed eval "Telemed.Release.migrate"
  ```
  """
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @doc """
  Rollback d'une migration vers une version spécifique.

  Exemple :
  ```
  /app/bin/telemed eval "Telemed.Release.rollback(Telemed.Repo, 20231015000000)"
  ```
  """
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Crée un compte administrateur par défaut.

  ⚠️  ATTENTION: Changez le mot de passe immédiatement après la première connexion !

  Utilisé lors du premier déploiement :
  ```
  /app/bin/telemed eval "Telemed.Release.create_admin"
  ```
  """
  def create_admin do
    load_app()

    {:ok, _} = Application.ensure_all_started(:telemed)

    admin_email = "admin@telemed.fr"
    admin_password = "Admin123!ChangeMe"

    case Telemed.Accounts.register_user(%{
      email: admin_email,
      password: admin_password,
      role: "admin",
      first_name: "Admin",
      last_name: "Telemed"
    }) do
      {:ok, user} ->
        IO.puts("\n✅ Compte administrateur créé avec succès !")
        IO.puts("   Email: #{admin_email}")
        IO.puts("   Mot de passe: #{admin_password}")
        IO.puts("\n⚠️  IMPORTANT: Changez ce mot de passe immédiatement après la première connexion !")
        IO.puts("   Login: https://votre-app.fly.dev/users/log_in\n")
        {:ok, user}

      {:error, %Ecto.Changeset{errors: errors}} ->
        if Keyword.has_key?(errors, :email) &&
           String.contains?(inspect(Keyword.get(errors, :email)), "already been taken") do
          IO.puts("\n✅ Compte admin existe déjà")
          {:ok, :already_exists}
        else
          IO.puts("\n❌ Erreur lors de la création du compte admin:")
          IO.inspect(errors)
          {:error, errors}
        end
    end
  end

  @doc """
  Crée un compte doctor de démonstration.
  """
  def create_demo_doctor do
    load_app()
    {:ok, _} = Application.ensure_all_started(:telemed)

    case Telemed.Accounts.register_user(%{
      email: "doctor@telemed.fr",
      password: "Doctor123!Demo",
      role: "doctor",
      first_name: "Dr. Jean",
      last_name: "Martin",
      speciality: "Médecine Générale"
    }) do
      {:ok, user} ->
        IO.puts("\n✅ Compte doctor de démo créé")
        IO.puts("   Email: doctor@telemed.fr")
        {:ok, user}

      {:error, _} ->
        IO.puts("\n✅ Compte doctor existe déjà")
        {:ok, :already_exists}
    end
  end

  @doc """
  Crée un compte patient de démonstration.
  """
  def create_demo_patient do
    load_app()
    {:ok, _} = Application.ensure_all_started(:telemed)

    case Telemed.Accounts.register_user(%{
      email: "patient@telemed.fr",
      password: "Patient123!Demo",
      role: "patient",
      first_name: "Marie",
      last_name: "Dubois"
    }) do
      {:ok, user} ->
        IO.puts("\n✅ Compte patient de démo créé")
        IO.puts("   Email: patient@telemed.fr")
        {:ok, user}

      {:error, _} ->
        IO.puts("\n✅ Compte patient existe déjà")
        {:ok, :already_exists}
    end
  end

  @doc """
  Setup complet pour la production : migrations + admin + comptes demo.
  """
  def setup_production do
    IO.puts("\n🚀 Configuration production Telemed...\n")

    IO.puts("1️⃣  Exécution des migrations...")
    migrate()
    IO.puts("✅ Migrations terminées\n")

    IO.puts("2️⃣  Création compte administrateur...")
    create_admin()

    IO.puts("\n3️⃣  Création comptes de démonstration...")
    create_demo_doctor()
    create_demo_patient()

    IO.puts("\n🎉 Configuration production terminée !")
    IO.puts("\n📝 Prochaines étapes:")
    IO.puts("   1. Connexion admin: https://votre-app.fly.dev/users/log_in")
    IO.puts("   2. Changer le mot de passe admin")
    IO.puts("   3. Tester Swagger: https://votre-app.fly.dev/swaggerui")
    IO.puts("   4. Créer vos premiers vrais utilisateurs\n")
  end

  # Helpers privés

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
