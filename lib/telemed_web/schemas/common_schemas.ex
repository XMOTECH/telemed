defmodule TelemedWeb.Schemas.Common do
  @moduledoc "Common OpenAPI Schemas"

  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule SuccessResponse do
    @moduledoc "Réponse succès générique"
    OpenApiSpex.schema(%{
      title: "SuccessResponse",
      description: "Réponse succès",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            message: %Schema{type: :string, example: "Opération réussie"}
          }
        }
      }
    })
  end

  defmodule UnauthorizedResponse do
    @moduledoc "Erreur 401"
    OpenApiSpex.schema(%{
      title: "UnauthorizedResponse",
      description: "Non authentifié",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            message: %Schema{type: :string, example: "Authentification requise"}
          }
        }
      }
    })
  end

  defmodule ForbiddenResponse do
    @moduledoc "Erreur 403"
    OpenApiSpex.schema(%{
      title: "ForbiddenResponse",
      description: "Accès interdit",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            message: %Schema{type: :string, example: "Accès interdit"}
          }
        }
      }
    })
  end

  defmodule NotFoundResponse do
    @moduledoc "Erreur 404"
    OpenApiSpex.schema(%{
      title: "NotFoundResponse",
      description: "Ressource non trouvée",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            message: %Schema{type: :string, example: "Ressource non trouvée"}
          }
        }
      }
    })
  end
end
