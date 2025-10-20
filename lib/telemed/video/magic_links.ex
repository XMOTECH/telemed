defmodule Telemed.Video.MagicLinks do
  @moduledoc """
  Système de liens magiques pour rejoindre une consultation en 1 clic.

  Comme WhatsApp:
  - Patient reçoit SMS avec lien
  - Clic → Auto-login → Dans la consultation
  - 0 friction, 0 configuration

  Utilise Phoenix.Token pour sécurité:
  - Signé cryptographiquement
  - Expire après 1h
  - Usage unique possible
  """

  require Logger
  alias Telemed.{Accounts, Notifications}

  @salt "instant_consultation_magic_link"
  @max_age 3600  # 1 heure

  @doc """
  Génère les magic links pour une consultation.

  Retourne:
  - doctor_link: Lien pour le médecin
  - patient_link: Lien pour le patient

  ## Exemples

      iex> MagicLinks.generate_links("room_123", doctor_id, patient_id)
      %{
        doctor_link: "https://telemed.fr/instant/eyJhbG...",
        patient_link: "https://telemed.fr/instant/eyJhbG..."
      }
  """
  def generate_links(room_id, doctor_id, patient_id, opts \\ []) do
    # Token docteur
    doctor_token = generate_token(room_id, doctor_id, "doctor")
    doctor_link = build_link(doctor_token)

    # Token patient
    patient_token = generate_token(room_id, patient_id, "patient")
    patient_link = build_link(patient_token)

    links = %{
      doctor_link: doctor_link,
      patient_link: patient_link,
      doctor_token: doctor_token,  # Ajouté pour les tests
      patient_token: patient_token  # Ajouté pour les tests
    }

    # Envoyer automatiquement (sauf si désactivé, ex: dans les tests)
    unless Keyword.get(opts, :skip_notifications, false) do
      Task.start(fn ->
        send_magic_links(doctor_id, patient_id, links)
      end)
    end

    links
  end

  @doc """
  Vérifie et décode un token magic link.

  ## Exemples

      iex> MagicLinks.verify_token("eyJhbGc...")
      {:ok, %{room_id: "room_123", user_id: 45, role: "doctor"}}
  """
  def verify_token(token) do
    case Phoenix.Token.verify(
      TelemedWeb.Endpoint,
      @salt,
      token,
      max_age: @max_age
    ) do
      {:ok, data} ->
        Logger.info("✅ Magic link verified for user #{data.user_id}")
        {:ok, data}

      {:error, :expired} ->
        Logger.warning("⏱️ Magic link expired")
        {:error, :expired}

      {:error, :invalid} ->
        Logger.warning("❌ Invalid magic link")
        {:error, :invalid}

      error ->
        Logger.error("Magic link verification error: #{inspect(error)}")
        {:error, :invalid}
    end
  end

  @doc """
  Crée une session utilisateur à partir d'un magic link.
  Auto-login sans mot de passe.
  """
  def auto_login(conn, token) do
    case verify_token(token) do
      {:ok, %{user_id: user_id, room_id: room_id, role: role}} ->
        # Récupérer l'utilisateur
        user = Accounts.get_user!(user_id)

        if user do
            # CRÉER UNE SESSION AUTOMATIQUEMENT
            conn = TelemedWeb.UserAuth.log_in_user(conn, user)

            {:ok, conn, room_id, role}
        end

      error ->
        error
    end
  end

  # ========== PRIVATE FUNCTIONS ==========

  defp generate_token(room_id, user_id, role) do
    data = %{
      room_id: room_id,
      user_id: user_id,
      role: role,
      generated_at: System.system_time(:nanosecond),  # Plus précis pour unicité
      nonce: :crypto.strong_rand_bytes(16) |> Base.encode64()  # Ajout d'un nonce aléatoire
    }

    Phoenix.Token.sign(TelemedWeb.Endpoint, @salt, data)
  end

  defp build_link(token) do
    base_url = TelemedWeb.Endpoint.url()
    "#{base_url}/instant/#{token}"
  end

  defp send_magic_links(doctor_id, patient_id, links) do
    Logger.info("📧 Sending magic links")
    Logger.info("   Doctor ID: #{inspect(doctor_id)} (type: #{inspect(is_integer(doctor_id))})")
    Logger.info("   Patient ID: #{inspect(patient_id)} (type: #{inspect(is_integer(patient_id))})")

    # Récupérer les utilisateurs
    doctor = Accounts.get_user!(doctor_id)
    patient = Accounts.get_user!(patient_id)

    Logger.info("   Doctor found: #{doctor.email} (ID: #{doctor.id})")
    Logger.info("   Patient found: #{patient.email} (ID: #{patient.id})")

    doctor_name = if doctor.first_name && doctor.last_name do
      "Dr. #{doctor.first_name} #{doctor.last_name}"
    else
      "Votre médecin"
    end

    # Notification docteur (avec lien cliquable dans message)
    Logger.info("📤 Creating notification for DOCTOR (user_id: #{inspect(doctor_id)})")
    {:ok, doctor_notif} = Notifications.create_notification(%{
      user_id: doctor_id,
      title: "✅ Consultation créée",
      message: "Lien envoyé au patient. Votre lien: #{links.doctor_link}",
      type: "video_ready"
    })
    Logger.info("   ✅ Doctor notification created: ID #{doctor_notif.id} for user #{doctor_notif.user_id}")

    # Notification patient (AVEC LE LIEN CLIQUABLE)
    Logger.info("📤 Creating notification for PATIENT (user_id: #{inspect(patient_id)})")
    {:ok, patient_notif} = Notifications.create_notification(%{
      user_id: patient_id,
      title: "🎥 #{doctor_name} vous appelle",
      message: "Consultation vidéo prête ! Cliquez ici pour rejoindre: #{links.patient_link}",
      type: "video_ready"
    })
    Logger.info("   ✅ Patient notification created: ID #{patient_notif.id} for user #{patient_notif.user_id}")

    Logger.info("✅ Notifications sent successfully!")
    Logger.info("   Doctor link: #{links.doctor_link}")
    Logger.info("   Patient link: #{links.patient_link}")

    # TODO: Envoyer SMS avec Twilio/autre service
    send_sms_if_configured(patient, links.patient_link)

    :ok
  end

  defp send_sms_if_configured(user, link) do
    if user.phone && sms_configured?() do
      message = """
      Dr. vous appelle pour une consultation vidéo.
      Rejoindre: #{link}
      """

      # TODO: Intégrer Twilio, Vonage, ou autre
      Logger.info("📱 SMS would be sent to #{user.phone}: #{message}")
      # Twilio.send_sms(user.phone, message)
    end
  end

  defp sms_configured? do
    # Vérifier si API SMS configurée
    !is_nil(System.get_env("TWILIO_ACCOUNT_SID"))
  end
end
