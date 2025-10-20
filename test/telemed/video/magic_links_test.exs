defmodule Telemed.Video.MagicLinksTest do
  use Telemed.DataCase, async: false

  alias Telemed.Video.MagicLinks
  alias Telemed.Accounts

  describe "Magic Links" do
    setup do
      # Créer des utilisateurs de test
      {:ok, doctor} = Accounts.register_user(%{
        email: "magic_doctor_#{:rand.uniform(10000)}@test.com",
        password: "Password123!",
        role: "doctor",
        first_name: "Magic",
        last_name: "Doctor"
      })

      {:ok, patient} = Accounts.register_user(%{
        email: "magic_patient_#{:rand.uniform(10000)}@test.com",
        password: "Password123!",
        role: "patient",
        first_name: "Magic",
        last_name: "Patient"
      })

      %{doctor: doctor, patient: patient}
    end

    test "génère des links uniques pour doctor et patient", %{doctor: doctor, patient: patient} do
      room_id = "test_room_#{:rand.uniform(10000)}"

      links = MagicLinks.generate_links(room_id, doctor.id, patient.id, skip_notifications: true)

      assert is_map(links)
      assert Map.has_key?(links, :doctor_link)
      assert Map.has_key?(links, :patient_link)
      assert Map.has_key?(links, :doctor_token)
      assert Map.has_key?(links, :patient_token)

      # Les tokens doivent être différents
      assert links.doctor_token != links.patient_token

      # Les liens doivent contenir le token
      assert String.contains?(links.doctor_link, links.doctor_token)
      assert String.contains?(links.patient_link, links.patient_token)
    end

    test "peut vérifier un token valide", %{doctor: doctor, patient: patient} do
      room_id = "verify_room_#{:rand.uniform(10000)}"
      links = MagicLinks.generate_links(room_id, doctor.id, patient.id, skip_notifications: true)

      # Vérifier token doctor
      assert {:ok, verified_data} = MagicLinks.verify_token(links.doctor_token)
      assert verified_data.room_id == room_id
      assert verified_data.user_id == doctor.id
      assert verified_data.role == "doctor"

      # Vérifier token patient
      assert {:ok, verified_data} = MagicLinks.verify_token(links.patient_token)
      assert verified_data.room_id == room_id
      assert verified_data.user_id == patient.id
      assert verified_data.role == "patient"
    end

    test "rejette un token invalide" do
      assert {:error, _reason} = MagicLinks.verify_token("invalid_token_123")
    end

    test "tokens contiennent les bonnes informations", %{doctor: doctor, patient: patient} do
      room_id = "info_room_#{:rand.uniform(10000)}"
      links = MagicLinks.generate_links(room_id, doctor.id, patient.id, skip_notifications: true)

      {:ok, doctor_data} = MagicLinks.verify_token(links.doctor_token)
      {:ok, patient_data} = MagicLinks.verify_token(links.patient_token)

      # Vérifier doctor
      assert doctor_data.room_id == room_id
      assert doctor_data.user_id == doctor.id
      assert doctor_data.role == "doctor"

      # Vérifier patient
      assert patient_data.room_id == room_id
      assert patient_data.user_id == patient.id
      assert patient_data.role == "patient"
    end

    test "génère des tokens différents à chaque appel", %{doctor: doctor, patient: patient} do
      room_id = "unique_room"

      links1 = MagicLinks.generate_links(room_id, doctor.id, patient.id, skip_notifications: true)
      :timer.sleep(10)  # Petit délai pour garantir timestamp différent
      links2 = MagicLinks.generate_links(room_id, doctor.id, patient.id, skip_notifications: true)

      # Les tokens doivent être différents même pour la même room
      assert links1.doctor_token != links2.doctor_token
      assert links1.patient_token != links2.patient_token
    end
  end
end
