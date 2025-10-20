defmodule Telemed.Video.InstantRoomTest do
  use Telemed.DataCase, async: false

  alias Telemed.Video.{RoomSupervisor, RoomRegistry}
  alias Telemed.Accounts

  describe "InstantRoom GenServer" do
    setup do
      # Créer des utilisateurs de test
      {:ok, doctor} = Accounts.register_user(%{
        email: "test_doctor_#{:rand.uniform(10000)}@test.com",
        password: "Password123!",
        role: "doctor",
        first_name: "Test",
        last_name: "Doctor"
      })

      {:ok, patient} = Accounts.register_user(%{
        email: "test_patient_#{:rand.uniform(10000)}@test.com",
        password: "Password123!",
        role: "patient",
        first_name: "Test",
        last_name: "Patient"
      })

      %{doctor: doctor, patient: patient}
    end

    test "démarre une consultation instantanée", %{doctor: doctor, patient: patient} do
      appointment_id = "test_#{:rand.uniform(10000)}"

      {:ok, pid, room_id, links} =
        RoomSupervisor.start_instant_consultation(appointment_id, doctor.id, patient.id)

      assert is_pid(pid)
      assert String.starts_with?(room_id, "instant_")
      assert is_map(links)
      assert Map.has_key?(links, :doctor_link)
      assert Map.has_key?(links, :patient_link)
      assert String.contains?(links.doctor_link, "/instant/")
      assert String.contains?(links.patient_link, "/instant/")

      # Nettoyer
      RoomSupervisor.stop_consultation(room_id)
    end

    test "room ID est unique à chaque création", %{doctor: doctor, patient: patient} do
      {:ok, _pid1, room_id1, _links1} =
        RoomSupervisor.start_instant_consultation("appt1", doctor.id, patient.id)

      {:ok, _pid2, room_id2, _links2} =
        RoomSupervisor.start_instant_consultation("appt2", doctor.id, patient.id)

      assert room_id1 != room_id2

      # Nettoyer
      RoomSupervisor.stop_consultation(room_id1)
      RoomSupervisor.stop_consultation(room_id2)
    end

    test "participants peuvent rejoindre la room", %{doctor: doctor, patient: patient} do
      {:ok, pid, room_id, _links} =
        RoomSupervisor.start_instant_consultation("appt_test", doctor.id, patient.id)

      # Simuler un participant qui rejoint
      GenServer.cast(pid, {:participant_joined, doctor.id, %{role: "doctor"}})
      :timer.sleep(50)

      # Vérifier l'état après 1 participant
      state1 = :sys.get_state(pid)
      assert map_size(state1.participants) == 1
      assert Map.has_key?(state1.participants, doctor.id)

      # Nettoyer
      RoomSupervisor.stop_consultation(room_id)
    end

    test "consultation démarre automatiquement avec 2 participants", %{doctor: doctor, patient: patient} do
      {:ok, pid, room_id, _links} =
        RoomSupervisor.start_instant_consultation("appt_auto", doctor.id, patient.id)

      # Vérifier état initial
      state1 = :sys.get_state(pid)
      assert state1.status == :waiting

      # Simuler participants qui rejoignent
      GenServer.cast(pid, {:participant_joined, doctor.id, %{}})
      :timer.sleep(100)

      GenServer.cast(pid, {:participant_joined, patient.id, %{}})
      :timer.sleep(300)  # Plus de temps pour traiter

      # Vérifier que le statut passe à active
      state2 = :sys.get_state(pid)
      assert state2.status == :active
      assert map_size(state2.participants) == 2

      # Nettoyer
      RoomSupervisor.stop_consultation(room_id)
    end

    test "peut arrêter une consultation", %{doctor: doctor, patient: patient} do
      {:ok, _pid, room_id, _links} =
        RoomSupervisor.start_instant_consultation("appt_stop", doctor.id, patient.id)

      # Vérifier que la room existe
      assert {:ok, _pid} = RoomRegistry.lookup(room_id)

      # Arrêter
      assert :ok = RoomSupervisor.stop_consultation(room_id)

      # Vérifier qu'elle n'existe plus
      :timer.sleep(100)
      assert {:error, :not_found} = RoomRegistry.lookup(room_id)
    end
  end
end
