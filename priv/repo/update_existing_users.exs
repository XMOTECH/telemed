# Script pour mettre à jour les utilisateurs existants avec des noms
# Exécuter avec: mix run priv/repo/update_existing_users.exs

alias Telemed.Repo
alias Telemed.Accounts.User

IO.puts("\n🔄 Mise à jour des utilisateurs existants...\n")

# Mettre à jour tous les users qui n'ont pas de first_name
users = Repo.all(User)

Enum.each(users, fn user ->
  if is_nil(user.first_name) do
    {first_name, last_name, speciality} = case user.email do
      "patient@example.com" -> {"Sophie", "Laurent", nil}
      "doctor@example.com" -> {"Martin", "Dupont", "Médecine Générale"}
      "dr.martin@example.com" -> {"Claire", "Martin", "Cardiologie"}
      "admin@example.com" -> {"Admin", "Système", nil}
      "marie.dupont@example.com" -> {"Marie", "Dupont", nil}
      _ ->
        # Pour les autres, extraire du email
        email_parts = String.split(user.email, "@") |> List.first() |> String.split(".")
        first = email_parts |> List.first() |> String.capitalize()
        last = if length(email_parts) > 1, do: email_parts |> List.last() |> String.capitalize(), else: "User"
        {first, last, nil}
    end

    user
    |> Ecto.Changeset.change(%{
      first_name: first_name,
      last_name: last_name,
      speciality: speciality
    })
    |> Repo.update!()

    IO.puts("✅ Mis à jour: #{first_name} #{last_name} (#{user.email})")
  end
end)

IO.puts("\n✨ Mise à jour terminée!\n")
