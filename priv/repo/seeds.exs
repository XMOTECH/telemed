# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Telemed.Repo.insert!(%Telemed.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Telemed.Accounts
alias Telemed.MedicalRecords
alias Telemed.Appointments
alias Telemed.Notifications
alias Telemed.Repo

IO.puts("\n🌱 Démarrage du seeding...\n")

# Créer les utilisateurs de test
{:ok, patient} = Accounts.register_user(%{
  email: "patient@example.com",
  password: "Password123!",
  role: "patient"
})

# Mettre à jour avec first_name et last_name
patient
|> Ecto.Changeset.change(%{
  first_name: "Sophie",
  last_name: "Laurent",
  phone: "+33 6 12 34 56 78",
  confirmed_at: DateTime.utc_now()
})
|> Repo.update!()

IO.puts("✅ Patient créé: Sophie Laurent (patient@example.com)")

{:ok, doctor} = Accounts.register_user(%{
  email: "doctor@example.com",
  password: "Password123!",
  role: "doctor"
})

doctor
|> Ecto.Changeset.change(%{
  first_name: "Martin",
  last_name: "Dupont",
  phone: "+33 6 98 76 54 32",
  speciality: "Médecine Générale",
  confirmed_at: DateTime.utc_now()
})
|> Repo.update!()

IO.puts("✅ Docteur créé: Dr. Martin Dupont (doctor@example.com)")

{:ok, doctor2} = Accounts.register_user(%{
  email: "dr.martin@example.com",
  password: "Password123!",
  role: "doctor"
})

doctor2
|> Ecto.Changeset.change(%{
  first_name: "Claire",
  last_name: "Martin",
  phone: "+33 6 55 44 33 22",
  speciality: "Cardiologie",
  confirmed_at: DateTime.utc_now()
})
|> Repo.update!()

IO.puts("✅ Docteur créé: Dr. Claire Martin (dr.martin@example.com)")

{:ok, admin} = Accounts.register_user(%{
  email: "admin@example.com",
  password: "Password123!",
  role: "admin"
})

admin
|> Ecto.Changeset.change(%{
  first_name: "Admin",
  last_name: "Système",
  confirmed_at: DateTime.utc_now()
})
|> Repo.update!()

IO.puts("✅ Admin créé: Admin Système (admin@example.com)")

# Créer des dossiers médicaux
{:ok, _record1} = MedicalRecords.create_medical_record(%{
  nom: "Sophie Laurent",
  age: 32,
  description: "Consultation de routine",
  user_id: patient.id,
  doctor_id: doctor.id,
  record_type: "consultation",
  content: "Patient en bonne santé générale. Pas de problèmes majeurs détectés.",
  confidentiality_level: "standard",
  diagnosis: "Aucun problème majeur",
  treatment_plan: "Contrôle annuel recommandé",
  status: "completed"
})

{:ok, _record2} = MedicalRecords.create_medical_record(%{
  nom: "Sophie Laurent",
  age: 32,
  description: "Suivi tension artérielle",
  user_id: patient.id,
  doctor_id: doctor2.id,
  record_type: "followup",
  content: "Tension artérielle légèrement élevée. Surveillance recommandée.",
  confidentiality_level: "standard",
  diagnosis: "Hypertension légère",
  treatment_plan: "Régime alimentaire et exercice. Contrôle dans 3 mois.",
  status: "active"
})

{:ok, _record3} = MedicalRecords.create_medical_record(%{
  nom: "Sophie Laurent",
  age: 32,
  description: "Résultats examens sanguins",
  user_id: patient.id,
  doctor_id: doctor.id,
  record_type: "labresults",
  content: "Examens sanguins dans les normes. Vitamine D légèrement basse.",
  confidentiality_level: "standard",
  diagnosis: "Légère carence en vitamine D",
  treatment_plan: "Supplémentation vitamine D 1000 UI/jour",
  status: "completed"
})

IO.puts("✅ 3 dossiers médicaux créés")

# Créer des rendez-vous
scheduled_time1 = DateTime.utc_now() |> DateTime.add(2, :day) |> DateTime.truncate(:second)
{:ok, appt1} = Appointments.create_appointment(%{
  patient_id: patient.id,
  doctor_id: doctor.id,
  scheduled_at: NaiveDateTime.new!(scheduled_time1.year, scheduled_time1.month, scheduled_time1.day, 10, 0, 0),
  notes: "Consultation de suivi pour tension artérielle",
  status: "confirmed"
})

scheduled_time2 = DateTime.utc_now() |> DateTime.add(7, :day) |> DateTime.truncate(:second)
{:ok, appt2} = Appointments.create_appointment(%{
  patient_id: patient.id,
  doctor_id: doctor2.id,
  scheduled_at: NaiveDateTime.new!(scheduled_time2.year, scheduled_time2.month, scheduled_time2.day, 14, 30, 0),
  notes: "Contrôle cardiologie",
  status: "pending"
})

IO.puts("✅ 2 rendez-vous créés")

# Créer des notifications
{:ok, _notif1} = Notifications.create_notification(%{
  user_id: patient.id,
  title: "Rendez-vous confirmé",
  message: "Votre rendez-vous avec Dr. Martin Dupont a été confirmé pour le #{Calendar.strftime(appt1.scheduled_at, "%d/%m/%Y à %H:%M")}",
  type: "appointment_confirmed",
  appointment_id: appt1.id,
  read: false
})

{:ok, _notif2} = Notifications.create_notification(%{
  user_id: doctor2.id,
  title: "Nouveau rendez-vous",
  message: "Nouveau rendez-vous demandé par Sophie Laurent pour le #{Calendar.strftime(appt2.scheduled_at, "%d/%m/%Y à %H:%M")}",
  type: "appointment_request",
  appointment_id: appt2.id,
  read: false
})

{:ok, _notif3} = Notifications.create_notification(%{
  user_id: patient.id,
  title: "Résultats disponibles",
  message: "Vos résultats d'examens sanguins sont disponibles dans votre dossier médical",
  type: "lab_results",
  read: false
})

{:ok, _notif4} = Notifications.create_notification(%{
  user_id: doctor.id,
  title: "Rappel",
  message: "Vous avez un rendez-vous demain à 10:00 avec Sophie Laurent",
  type: "reminder",
  read: true
})

IO.puts("✅ 4 notifications créées")

IO.puts("\n✨ Seeding terminé avec succès!\n")
IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
IO.puts("📋 COMPTES DE TEST CRÉÉS :")
IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
IO.puts("\n👤 PATIENT:")
IO.puts("   Email: patient@example.com")
IO.puts("   Password: Password123!")
IO.puts("   Nom: Sophie Laurent")
IO.puts("\n👨‍⚕️ DOCTEUR 1:")
IO.puts("   Email: doctor@example.com")
IO.puts("   Password: Password123!")
IO.puts("   Nom: Dr. Martin Dupont")
IO.puts("   Spécialité: Médecine Générale")
IO.puts("\n👨‍⚕️ DOCTEUR 2:")
IO.puts("   Email: dr.martin@example.com")
IO.puts("   Password: Password123!")
IO.puts("   Nom: Dr. Claire Martin")
IO.puts("   Spécialité: Cardiologie")
IO.puts("\n🛡️ ADMIN:")
IO.puts("   Email: admin@example.com")
IO.puts("   Password: Password123!")
IO.puts("   Nom: Admin Système")
IO.puts("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
