defmodule TelemedWeb.Schemas.Appointment do
  @moduledoc "OpenAPI Schemas for Appointments"

  alias OpenApiSpex.Schema

  defmodule AppointmentRequest do
    @moduledoc "Requête création RDV"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "AppointmentRequest",
      description: "Données pour créer un RDV",
      type: :object,
      properties: %{
        appointment: %Schema{
          type: :object,
          required: [:scheduled_at],
          properties: %{
            patient_id: %Schema{type: :integer, example: 1, description: "ID patient (optionnel si patient connecté)"},
            doctor_id: %Schema{type: :integer, example: 2, description: "ID médecin"},
            scheduled_at: %Schema{type: :string, format: :"date-time", example: "2025-10-25T14:00:00Z"},
            notes: %Schema{type: :string, example: "Consultation de suivi"},
            status: %Schema{type: :string, enum: ["pending", "confirmed", "cancelled", "completed"], example: "pending"}
          }
        }
      },
      example: %{
        "appointment" => %{
          "doctor_id" => 2,
          "scheduled_at" => "2025-10-25T14:00:00Z",
          "notes" => "Consultation de suivi hypertension"
        }
      }
    })
  end

  defmodule AppointmentResponse do
    @moduledoc "Réponse avec un RDV"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "AppointmentResponse",
      description: "Rendez-vous médical",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :integer, example: 1},
            patient_id: %Schema{type: :integer, example: 1},
            doctor_id: %Schema{type: :integer, example: 2},
            scheduled_at: %Schema{type: :string, format: :"date-time", example: "2025-10-25T14:00:00Z"},
            status: %Schema{type: :string, enum: ["pending", "confirmed", "cancelled", "completed"], example: "pending"},
            notes: %Schema{type: :string, example: "Consultation de suivi"},
            inserted_at: %Schema{type: :string, format: :"date-time", example: "2025-10-19T10:00:00Z"},
            updated_at: %Schema{type: :string, format: :"date-time", example: "2025-10-19T10:00:00Z"}
          }
        }
      },
      example: %{
        "data" => %{
          "id" => 1,
          "patient_id" => 1,
          "doctor_id" => 2,
          "scheduled_at" => "2025-10-25T14:00:00Z",
          "status" => "pending",
          "notes" => "Consultation de suivi",
          "inserted_at" => "2025-10-19T10:00:00Z",
          "updated_at" => "2025-10-19T10:00:00Z"
        }
      }
    })
  end

  defmodule AppointmentListResponse do
    @moduledoc "Liste de RDV"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "AppointmentListResponse",
      description: "Liste des rendez-vous",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            properties: %{
              id: %Schema{type: :integer, example: 1},
              patient_id: %Schema{type: :integer, example: 1},
              doctor_id: %Schema{type: :integer, example: 2},
              scheduled_at: %Schema{type: :string, format: :"date-time", example: "2025-10-25T14:00:00Z"},
              status: %Schema{type: :string, example: "pending"},
              notes: %Schema{type: :string, example: "Consultation de suivi"}
            }
          }
        }
      },
      example: %{
        "data" => [
          %{
            "id" => 1,
            "patient_id" => 1,
            "doctor_id" => 2,
            "scheduled_at" => "2025-10-25T14:00:00Z",
            "status" => "pending",
            "notes" => "Consultation de suivi"
          }
        ]
      }
    })
  end
end
