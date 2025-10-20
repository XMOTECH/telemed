defmodule TelemedWeb.InstantController do
  @moduledoc """
  Controller pour les consultations instantanées via magic links.
  """

  use TelemedWeb, :controller
  require Logger

  alias Telemed.Video.{MagicLinks, InstantRoom, RoomSupervisor}
  alias Telemed.Accounts

  @doc """
  Rejoindre une consultation via magic link.
  Auto-login + redirection vers la consultation.
  """
  def join(conn, %{"token" => token}) do
    case MagicLinks.verify_token(token) do
      {:ok, %{user_id: user_id, room_id: room_id, role: role}} ->
        # Récupérer l'utilisateur
        user = Accounts.get_user!(user_id)

        if user do
            # AUTO-LOGIN (comme WhatsApp!)
            conn = TelemedWeb.UserAuth.log_in_user(conn, user)

            # Notifier la room que le participant a rejoint
            InstantRoom.participant_joined(room_id, user_id, %{role: role})

            # Rediriger vers la consultation
            redirect(conn, to: ~p"/instant/room/#{room_id}")
        end

      {:error, :expired} ->
        conn
        |> put_flash(:error, "Ce lien a expiré. Veuillez demander un nouveau lien.")
        |> redirect(to: ~p"/")

      {:error, _} ->
        conn
        |> put_flash(:error, "Lien invalide")
        |> redirect(to: ~p"/")
    end
  end

  @doc """
  Page de consultation instantanée.
  """
  def room(conn, %{"room_id" => room_id}) do
    current_user = conn.assigns.current_user

    case InstantRoom.get_info(room_id) do
      {:ok, room_info} ->
        # Vérifier que l'utilisateur est autorisé
        if current_user.id in [room_info.doctor_id, room_info.patient_id] do
          render(conn, :room,
            room_id: room_id,
            room_info: room_info,
            user_id: current_user.id,
            user_name: get_user_display_name(current_user),
            user_role: current_user.role
          )
        else
          conn
          |> put_flash(:error, "Vous n'êtes pas autorisé à accéder à cette consultation")
          |> redirect(to: ~p"/dashboard")
        end

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Consultation non trouvée")
        |> redirect(to: ~p"/dashboard")
    end
  end

  @doc """
  Démarrer une consultation instantanée (pour le docteur).
  """
  def start_instant(conn, %{"appointment_id" => appointment_id, "patient_id" => patient_id}) do
    current_user = conn.assigns.current_user

    # Convertir patient_id en integer
    patient_id_int = String.to_integer(patient_id)

    # Seul un docteur peut démarrer
    if current_user.role != "doctor" do
      conn
      |> put_flash(:error, "Seul un médecin peut démarrer une consultation")
      |> redirect(to: ~p"/dashboard")
    else
      case RoomSupervisor.start_instant_consultation(appointment_id, current_user.id, patient_id_int) do
        {:ok, _pid, room_id, links} ->
          Logger.info("🎉 Consultation created successfully!")
          Logger.info("   Room ID: #{room_id}")
          Logger.info("   Doctor link: #{links.doctor_link}")
          Logger.info("   Patient link: #{links.patient_link}")

          conn
          |> put_flash(:info, "✅ Consultation créée! Le patient a reçu un lien dans ses notifications.")
          |> redirect(to: ~p"/instant/room/#{room_id}")

        {:error, reason} ->
          conn
          |> put_flash(:error, "Erreur: #{inspect(reason)}")
          |> redirect(to: ~p"/appointments")
      end
    end
  end

  # ========== HELPERS ==========

  defp get_user_display_name(user) do
    cond do
      user.first_name && user.last_name ->
        "#{user.first_name} #{user.last_name}"

      user.first_name ->
        user.first_name

      true ->
        user.email
    end
  end
end
