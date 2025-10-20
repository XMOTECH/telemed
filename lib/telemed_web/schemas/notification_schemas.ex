defmodule TelemedWeb.Schemas.Notification do
  @moduledoc """
  Schemas OpenAPI pour les notifications
  """

  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule NotificationResponse do
    @moduledoc "Réponse contenant une notification"
    OpenApiSpex.schema(%{
      title: "NotificationResponse",
      description: "Notification temps réel",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, example: 1},
        title: %Schema{
          type: :string,
          description: "Titre de la notification",
          example: "Nouveau rendez-vous confirmé"
        },
        message: %Schema{
          type: :string,
          description: "Message détaillé",
          example: "Dr. Martin a confirmé votre rendez-vous du 25 octobre à 14h"
        },
        type: %Schema{
          type: :string,
          enum: ["appointment_created", "appointment_confirmed", "appointment_cancelled", "video_ready", "result_available"],
          description: "Type de notification",
          example: "appointment_confirmed"
        },
        read: %Schema{
          type: :boolean,
          description: "Notification lue ou non",
          example: false
        },
        user_id: %Schema{type: :integer, example: 1},
        appointment_id: %Schema{
          type: :integer,
          nullable: true,
          description: "ID rendez-vous associé (si applicable)",
          example: 1
        },
        inserted_at: %Schema{type: :string, format: :"date-time"},
        updated_at: %Schema{type: :string, format: :"date-time"}
      },
      example: %{
        "id" => 1,
        "title" => "Nouveau rendez-vous confirmé",
        "message" => "Dr. Martin a confirmé votre rendez-vous du 25 octobre à 14h",
        "type" => "appointment_confirmed",
        "read" => false,
        "user_id" => 1,
        "appointment_id" => 1,
        "inserted_at" => "2025-10-19T10:00:00Z",
        "updated_at" => "2025-10-19T10:00:00Z"
      }
    })
  end

  defmodule NotificationListResponse do
    @moduledoc "Liste de notifications"
    OpenApiSpex.schema(%{
      title: "NotificationListResponse",
      description: "Liste des notifications utilisateur",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: NotificationResponse
        },
        meta: %Schema{
          type: :object,
          properties: %{
            unread_count: %Schema{
              type: :integer,
              description: "Nombre de notifications non lues",
              example: 3
            }
          }
        }
      }
    })
  end
end
