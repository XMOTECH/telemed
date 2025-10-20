defmodule TelemedWeb.Schemas.User do
  @moduledoc """
  Schemas OpenAPI pour les utilisateurs
  """

  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule UserResponse do
    @moduledoc "Réponse contenant un utilisateur"
    OpenApiSpex.schema(%{
      title: "UserResponse",
      description: "Profil utilisateur",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, example: 1},
        email: %Schema{
          type: :string,
          format: :email,
          example: "patient@telemed.fr"
        },
        role: %Schema{
          type: :string,
          enum: ["patient", "doctor", "admin"],
          example: "patient"
        },
        first_name: %Schema{
          type: :string,
          nullable: true,
          example: "Jean"
        },
        last_name: %Schema{
          type: :string,
          nullable: true,
          example: "Dupont"
        },
        phone: %Schema{
          type: :string,
          nullable: true,
          example: "+33612345678"
        },
        speciality: %Schema{
          type: :string,
          nullable: true,
          description: "Spécialité médicale (pour doctors)",
          example: "Cardiologie"
        },
        confirmed_at: %Schema{
          type: :string,
          format: :"date-time",
          nullable: true,
          description: "Date de confirmation email",
          example: "2025-10-19T10:00:00Z"
        },
        inserted_at: %Schema{type: :string, format: :"date-time"},
        updated_at: %Schema{type: :string, format: :"date-time"}
      },
      example: %{
        "id" => 1,
        "email" => "patient@telemed.fr",
        "role" => "patient",
        "first_name" => "Jean",
        "last_name" => "Dupont",
        "phone" => "+33612345678",
        "confirmed_at" => "2025-10-19T10:00:00Z",
        "inserted_at" => "2025-10-19T10:00:00Z",
        "updated_at" => "2025-10-19T10:00:00Z"
      }
    })
  end

  defmodule UpdateUserRequest do
    @moduledoc "Requête de mise à jour profil"
    OpenApiSpex.schema(%{
      title: "UpdateUserRequest",
      description: "Données pour modifier le profil utilisateur",
      type: :object,
      properties: %{
        user: %Schema{
          type: :object,
          properties: %{
            first_name: %Schema{
              type: :string,
              description: "Prénom",
              example: "Jean"
            },
            last_name: %Schema{
              type: :string,
              description: "Nom de famille",
              example: "Dupont"
            },
            phone: %Schema{
              type: :string,
              description: "Numéro de téléphone",
              example: "+33612345678"
            },
            speciality: %Schema{
              type: :string,
              description: "Spécialité médicale (doctors uniquement)",
              example: "Cardiologie"
            }
          }
        }
      },
      example: %{
        "user" => %{
          "first_name" => "Jean",
          "last_name" => "Dupont",
          "phone" => "+33612345678"
        }
      }
    })
  end
end
