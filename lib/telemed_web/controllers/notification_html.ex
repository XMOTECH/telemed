defmodule TelemedWeb.NotificationHTML do
  use TelemedWeb, :html

  embed_templates "notification_html/*"

  def format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y à %H:%M")
  end

  def notification_icon(type) do
    case type do
      "video_ready" -> "🎥"
      "appointment_created" -> "📅"
      "appointment_confirmed" -> "✅"
      "appointment_rejected" -> "❌"
      "appointment_cancelled" -> "🚫"
      _ -> "🔔"
    end
  end

  def notification_class(type) do
    case type do
      "video_ready" -> "bg-green-50 border-green-200"
      "appointment_created" -> "bg-blue-50 border-blue-200"
      "appointment_confirmed" -> "bg-green-50 border-green-200"
      "appointment_rejected" -> "bg-red-50 border-red-200"
      "appointment_cancelled" -> "bg-gray-50 border-gray-200"
      _ -> "bg-yellow-50 border-yellow-200"
    end
  end

  @doc "Extrait le lien d'un message de notification"
  def extract_link(message) do
    # Regex pour trouver les URLs
    case Regex.run(~r/(https?:\/\/[^\s]+|\/instant\/[^\s]+)/, message) do
      [link | _] -> link
      nil -> nil
    end
  end

  @doc "Extrait le message sans le lien"
  def extract_message_without_link(message) do
    message
    |> String.replace(~r/(https?:\/\/[^\s]+|\/instant\/[^\s]+)/, "")
    |> String.replace("Cliquez ici pour rejoindre:", "")
    |> String.trim()
  end
end
