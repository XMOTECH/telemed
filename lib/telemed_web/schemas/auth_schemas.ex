defmodule TelemedWeb.Schemas.Auth do
  @moduledoc """
  Schemas OpenAPI pour l'authentification
  """

  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule RegisterRequest do
    @moduledoc "Requête d'inscription"
    OpenApiSpex.schema(%{
      title: "RegisterRequest",
      description: "Données requises pour créer un compte",
      type: :object,
      properties: %{
        user: %Schema{
          type: :object,
          required: [:email, :password, :role],
          properties: %{
            email: %Schema{
              type: :string,
              format: :email,
              description: "Adresse email unique",
              example: "patient@telemed.fr"
            },
            password: %Schema{
              type: :string,
              format: :password,
              minLength: 12,
              description: "Mot de passe (min 12 caractères)",
              example: "MotDePasse123!"
            },
            role: %Schema{
              type: :string,
              enum: ["patient", "doctor", "admin"],
              description: "Rôle de l'utilisateur",
              example: "patient"
            },
            first_name: %Schema{
              type: :string,
              description: "Prénom (optionnel)",
              example: "Jean"
            },
            last_name: %Schema{
              type: :string,
              description: "Nom (optionnel)",
              example: "Dupont"
            }
          }
        }
      },
      required: [:user],
      example: %{
        "user" => %{
          "email" => "patient@telemed.fr",
          "password" => "MotDePasse123!",
          "role" => "patient",
          "first_name" => "Jean",
          "last_name" => "Dupont"
        }
      }
    })
  end

  defmodule LoginRequest do
    @moduledoc "Requête de connexion"
    OpenApiSpex.schema(%{
      title: "LoginRequest",
      description: "Identifiants de connexion",
      type: :object,
      required: [:email, :password],
      properties: %{
        email: %Schema{
          type: :string,
          format: :email,
          description: "Adresse email du compte",
          example: "doctor@telemed.fr"
        },
        password: %Schema{
          type: :string,
          format: :password,
          description: "Mot de passe",
          example: "Password123!"
        }
      },
      example: %{
        "email" => "doctor@telemed.fr",
        "password" => "Password123!"
      }
    })
  end

  defmodule RefreshTokenRequest do
    @moduledoc "Requête de refresh token"
    OpenApiSpex.schema(%{
      title: "RefreshTokenRequest",
      description: "Token de rafraîchissement",
      type: :object,
      required: [:refresh_token],
      properties: %{
        refresh_token: %Schema{
          type: :string,
          description: "Refresh token JWT",
          example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        }
      }
    })
  end

  defmodule AuthResponse do
    @moduledoc "Réponse d'authentification réussie"
    OpenApiSpex.schema(%{
      title: "AuthResponse",
      description: "Réponse contenant les tokens et données utilisateur",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            user: %Schema{
              type: :object,
              properties: %{
                id: %Schema{type: :integer, example: 1},
                email: %Schema{type: :string, example: "patient@telemed.fr"},
                role: %Schema{type: :string, example: "patient"},
                first_name: %Schema{type: :string, example: "Jean"},
                last_name: %Schema{type: :string, example: "Dupont"},
                confirmed_at: %Schema{type: :string, format: :"date-time", nullable: true},
                inserted_at: %Schema{type: :string, format: :"date-time"}
              }
            },
            tokens: %Schema{
              type: :object,
              properties: %{
                access_token: %Schema{
                  type: :string,
                  description: "Token d'accès JWT (valide 1h)",
                  example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                },
                refresh_token: %Schema{
                  type: :string,
                  description: "Token de rafraîchissement (valide 30j)",
                  example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                },
                token_type: %Schema{type: :string, example: "Bearer"},
                expires_in: %Schema{
                  type: :integer,
                  description: "Durée de validité en secondes",
                  example: 3600
                }
              }
            }
          }
        }
      },
      example: %{
        "data" => %{
          "user" => %{
            "id" => 1,
            "email" => "patient@telemed.fr",
            "role" => "patient",
            "first_name" => "Jean",
            "last_name" => "Dupont",
            "confirmed_at" => "2025-10-19T10:00:00Z",
            "inserted_at" => "2025-10-19T10:00:00Z"
          },
          "tokens" => %{
            "access_token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImV4cCI6MTcyOTQwNDAwMH0...",
            "refresh_token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImV4cCI6MTczMjAzMjAwMH0...",
            "token_type" => "Bearer",
            "expires_in" => 3600
          }
        }
      }
    })
  end

  defmodule ErrorResponse do
    @moduledoc "Réponse d'erreur standard"
    OpenApiSpex.schema(%{
      title: "ErrorResponse",
      description: "Format standard des erreurs API",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            message: %Schema{
              type: :string,
              description: "Message d'erreur lisible",
              example: "Email déjà utilisé"
            },
            details: %Schema{
              type: :object,
              description: "Détails supplémentaires (optionnel)",
              nullable: true
            }
          }
        }
      },
      example: %{
        "error" => %{
          "message" => "Email déjà utilisé",
          "details" => %{
            "email" => ["has already been taken"]
          }
        }
      }
    })
  end
end
